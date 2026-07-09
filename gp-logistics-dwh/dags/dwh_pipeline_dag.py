from datetime import date, datetime, timezone, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

from utils.dv_loader import execute_statements, load_phase
from utils.ext_diff import create_ext_table, read_last_batch_ts
from utils.ext_diff_templates import BUSINESS_COLUMNS
from utils.marts import FILL_MARTS, last_day_of_month, month_start

GP_CONN = "greenplum_default"

STAGE_SOURCES = [
    ("customers", "stg.customers"), ("drivers", "stg.drivers"), ("trucks", "stg.trucks"),
    ("trailers", "stg.trailers"), ("facilities", "stg.facilities"), ("routes", "stg.routes"),
    ("loads", "stg.loads"), ("trips", "stg.trips"), ("delivery_events", "stg.delivery_events"),
    ("fuel_purchases", "stg.fuel_purchases"), ("maintenance_records", "stg.maintenance_records"),
    ("safety_incidents", "stg.safety_incidents"),
]

CHANGED_MONTHS_SQL = """
 SELECT date_trunc('month', load_date_value)::date      FROM stg.loads               WHERE batch_id = %s AND load_date_value    IS NOT NULL
 UNION
 SELECT date_trunc('month', dispatch_date)::date        FROM stg.trips               WHERE batch_id = %s AND dispatch_date      IS NOT NULL
 UNION
 SELECT date_trunc('month', actual_datetime)::date      FROM stg.delivery_events     WHERE batch_id = %s AND actual_datetime     IS NOT NULL
 UNION
 SELECT date_trunc('month', purchase_date)::date        FROM stg.fuel_purchases      WHERE batch_id = %s AND purchase_date       IS NOT NULL
 UNION
 SELECT date_trunc('month', maintenance_date)::date     FROM stg.maintenance_records WHERE batch_id = %s AND maintenance_date    IS NOT NULL
 UNION
 SELECT date_trunc('month', incident_date)::date        FROM stg.safety_incidents    WHERE batch_id = %s AND incident_date       IS NOT NULL
 UNION
 SELECT date_trunc('month', load_date)::date            FROM stg.customers           WHERE batch_id = %s AND load_date           IS NOT NULL
 UNION
 SELECT date_trunc('month', load_date)::date            FROM stg.drivers           WHERE batch_id = %s AND load_date           IS NOT NULL
 UNION
 SELECT date_trunc('month', load_date)::date            FROM stg.trucks           WHERE batch_id = %s AND load_date           IS NOT NULL
 UNION
 SELECT date_trunc('month', load_date)::date            FROM stg.trailers           WHERE batch_id = %s AND load_date           IS NOT NULL
 UNION
 SELECT date_trunc('month', load_date)::date            FROM stg.facilities           WHERE batch_id = %s AND load_date           IS NOT NULL
 UNION
 SELECT date_trunc('month', load_date)::date            FROM stg.routes           WHERE batch_id = %s AND load_date           IS NOT NULL
"""


def _begin(**kwargs):
    hook = PostgresHook(GP_CONN)
    current_ts = datetime.now(timezone.utc).replace(microsecond=0, tzinfo=None).strftime("%Y-%m-%d %H:%M:%S")
    conn = hook.get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO meta.load_batches "
                "  (batch_ts, target_schema, target_table, source_name, status, started_at) "
                "VALUES (now(), 'dds', 'dv_load', 'pg_logistics', 'RUNNING', now()) "
                "RETURNING batch_id"
            )
            batch_id = cur.fetchone()[0]
        conn.commit()
    finally:
        conn.close()
    return {"batch_id": batch_id, "load_timestamp": current_ts}


STG_COL_MAP = {"loads": {"load_date": "load_date_value"}}


def _load_stage(**kwargs):
    hook = PostgresHook(GP_CONN)
    info = kwargs["ti"].xcom_pull(task_ids="begin")
    batch_id = int(info["batch_id"])
    current_batch_ts = info["load_timestamp"]
    for pg_table, stg_table in STAGE_SOURCES:
        last_batch_ts = read_last_batch_ts(hook, stg_table)
        create_ext_table(hook, pg_table)          
        bis_cols = BUSINESS_COLUMNS[pg_table]   
        cmap = STG_COL_MAP.get(pg_table, {})
        stg_cols = [cmap.get(col, col) for col in bis_cols]  
        execute_statements(hook, [
            "INSERT INTO %s (%s, is_deleted, load_date, source_name, batch_id) "
            "SELECT %s, is_deleted, now(), 'pg_logistics', %d "
            "FROM ext.%s_diff "
            "WHERE updated_at > timestamp '%s' "
            "  AND updated_at <= timestamp '%s';"
            "  ANALYZE %s;" % (
                stg_table,
                ", ".join(stg_cols),
                ", ".join(bis_cols),
                batch_id, pg_table,
                last_batch_ts, current_batch_ts, stg_table
            )
        ])
    return None


def _detect_changed_months(**kwargs):
    hook = PostgresHook(GP_CONN)
    batch_id = int(kwargs["ti"].xcom_pull(task_ids="begin")["batch_id"])
    rows = hook.get_records(CHANGED_MONTHS_SQL, parameters=(batch_id,) * 12)
    months = sorted({month_start(row[0]).isoformat() for row in rows if row and row[0] is not None})
    return months


def _fill_marts(**kwargs):
    months = kwargs["ti"].xcom_pull(task_ids="detect_changed_months") or []
    hook = PostgresHook(GP_CONN)
    total = 0
    for month in months:
        d_from = date.fromisoformat(month)
        d_to = last_day_of_month(d_from)
        for mart_fn in FILL_MARTS:
            hook.run(f"SELECT dm.{mart_fn}(date '{d_from.isoformat()}', date '{d_to.isoformat()}');")
            total += 1
    print(f"[fill_marts] {total} перерасчётов за {len(months)} мес.")
    return total


def _end(**kwargs):
    hook = PostgresHook(GP_CONN)
    info = kwargs["ti"].xcom_pull(task_ids="begin")
    batch_id = int(info["batch_id"])
    current_batch_ts = info["load_timestamp"]
    execute_statements(hook, [
        f"UPDATE meta.load_batches SET status='SUCCESS', ended_at=now() WHERE batch_id={batch_id};",
        f"UPDATE meta.batch_history "
        f"SET last_batch_ts=timestamp '{current_batch_ts}', batch_id={batch_id}, updated_at=now();",
    ])
    return batch_id


with DAG(
    dag_id="dwh_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule=timedelta(hours=1),
    catchup=False,
    tags=["greenplum"],
    default_args={"owner": "data", "retries": 0},
) as dag:

    begin = PythonOperator(
        task_id="begin", 
        python_callable=_begin
    )
    
    load_stage = PythonOperator(
        task_id="load_stage", 
        python_callable=_load_stage
    )
    
    load_hubs = PythonOperator(
        task_id="load_hubs", 
        python_callable=load_phase, 
        op_kwargs={"load_order": 1}
    )
    
    load_links = PythonOperator(
        task_id="load_links", 
        python_callable=load_phase, 
        op_kwargs={"load_order": 2}
    )
    
    load_sats = PythonOperator(
        task_id="load_sats", 
        python_callable=load_phase, 
        op_kwargs={"load_order": 3}
    )
    
    load_sts = PythonOperator(
        task_id="load_sts", 
        python_callable=load_phase, 
        op_kwargs={"load_order": 4}
    )
    
    detect_changed_months = PythonOperator(
        task_id="detect_changed_months", 
        python_callable=_detect_changed_months
    )
    
    fill_marts = PythonOperator(
        task_id="fill_marts", 
        python_callable=_fill_marts
    )
    
    end = PythonOperator(
        task_id="end", 
        python_callable=_end
    )

    begin >> load_stage
    load_stage >> load_hubs >> load_links >> load_sats >> load_sts >> fill_marts
    load_stage >> detect_changed_months
    detect_changed_months >> fill_marts
    load_sts >> end
