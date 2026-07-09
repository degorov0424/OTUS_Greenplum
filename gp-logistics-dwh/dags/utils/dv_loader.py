import json

SOURCE_NAME = "pg_logistics"
NULL_TOKEN = "<NULL>" 



def fetch_mapping(greenplum_hook, load_order):
    rows = greenplum_hook.get_records(
        "SELECT target_type, target_table, source_table, bk_column, hk_column, "
        "       business_date_column, participants, attributes "
        "FROM meta.dv_mapping "
        "WHERE load_order = %s AND enabled = true "
        "ORDER BY target_table",
        parameters=(load_order,),
    )
    mappings = []
    for row in rows:
        mappings.append({
            "target_type": row[0],
            "target_table": row[1],
            "source_table": row[2],
            "bk_column": row[3],
            "hk_column": row[4],
            "business_date_column": row[5],
            "participants": _parse_json(row[6]),
            "attributes": _parse_json(row[7]),
        })
    return mappings


def _parse_json(json_value):
    if json_value is None:
        return None
    if isinstance(json_value, (list, dict)):
        return json_value 
    return json.loads(json_value)



def generate_sql(mapping, batch_id, load_timestamp):
    target_type = mapping["target_type"]
    if target_type == "hub":
        return _build_hub_sql(mapping, batch_id, load_timestamp)
    if target_type == "link":
        return _build_link_sql(mapping, batch_id, load_timestamp)
    if target_type == "sat":
        return _build_sat_sql(mapping, batch_id, load_timestamp)
    if target_type == "sts":
        return _build_sts_sql(mapping, batch_id, load_timestamp)
    raise ValueError(f"unknown target_type: {target_type}")


def _temp_table_name(source_table):
    return "tmp_batch_" + source_table.split(".")[1]


def _hash_key_expression(business_key_column):
    return f"md5(upper(trim({business_key_column}::text)))"


def _build_hub_sql(mapping, batch_id, load_timestamp):
    source_table = mapping["source_table"]
    business_key_column = mapping["bk_column"]
    hub_key_column = mapping["hk_column"]
    target_hub = mapping["target_table"]
    business_key_target_column = hub_key_column[:-3] + "_bk"
    temp_table = _temp_table_name(source_table)
    batch_id = int(batch_id)
    return [
        f"DROP TABLE IF EXISTS {temp_table};",
        (f"CREATE TEMP TABLE {temp_table} AS "
         f"SELECT {business_key_column} AS business_key_raw, "
         f"{_hash_key_expression(business_key_column)} AS {hub_key_column} "
         f"FROM (SELECT {business_key_column}, load_date, "
         f"row_number() OVER (PARTITION BY {business_key_column} ORDER BY load_date DESC) AS row_num "
         f"FROM {source_table} WHERE batch_id = {batch_id}) d "
         f"WHERE row_num = 1 AND {business_key_column} IS NOT NULL "
         f"DISTRIBUTED BY ({hub_key_column});"),
        (f"INSERT INTO {target_hub} ({hub_key_column}, {business_key_target_column}, load_date, source_name, batch_id) "
         f"SELECT {hub_key_column}, business_key_raw, timestamp '{load_timestamp}', '{SOURCE_NAME}', {batch_id} "
         f"FROM {temp_table} source_rows "
         f"WHERE NOT EXISTS (SELECT 1 FROM {target_hub} existing_hub "
         f"                  WHERE existing_hub.{hub_key_column} = source_rows.{hub_key_column});"),
         f"DROP TABLE IF EXISTS {temp_table};"
         f"ANALYZE {target_hub};"
    ]


def _build_link_sql(mapping, batch_id, load_timestamp):
    source_table = mapping["source_table"]
    target_link = mapping["target_table"]
    link_hk_column = mapping["hk_column"]
    participants = mapping["participants"]
    hub_key_columns = [participant["hk"] for participant in participants]

    select_expressions = ", ".join(
        f"{_hash_key_expression(participant['fk'])} AS {participant['hk']}"
        for participant in participants
    )
    not_null_filter = " AND ".join(
        f"{participant['fk']} IS NOT NULL" for participant in participants
    )
   
    link_hk_expr = "md5(" + " || '|' || ".join(hub_key_columns) + ")"
  
    link_hk_expr_qualified = "md5(" + " || '|' || ".join(
        f"source_rows.{c}" for c in hub_key_columns
    ) + ")"
    insert_columns = ", ".join([link_hk_column] + hub_key_columns)
    batch_id = int(batch_id)
    return [
        (f"INSERT INTO {target_link} ({insert_columns}, load_date, source_name, batch_id) "
         f"SELECT {link_hk_expr}, {', '.join(hub_key_columns)}, "
         f"timestamp '{load_timestamp}', '{SOURCE_NAME}', {batch_id} "
         f"FROM (SELECT DISTINCT {select_expressions} FROM {source_table} "
         f"      WHERE batch_id = {batch_id} AND {not_null_filter}) source_rows "
         f"WHERE NOT EXISTS (SELECT 1 FROM {target_link} existing_link "
         f"                  WHERE existing_link.{link_hk_column} = {link_hk_expr_qualified});"
         f"ANALYZE {target_link};")
    ]


def _build_sat_sql(mapping, batch_id, load_timestamp):
    source_table = mapping["source_table"]
    target_satellite = mapping["target_table"]
    business_key_column = mapping["bk_column"]
    hub_key_column = mapping["hk_column"]
    attributes = mapping["attributes"]  # [{"src":..,"tgt":..}, ...]
    temp_table = _temp_table_name(source_table)
    batch_id = int(batch_id)

    source_columns = ", ".join(attribute["src"] for attribute in attributes)
    hash_diff_expr = (
        "md5(concat_ws('~', "
        + ", ".join(
            f"coalesce({attribute['src']}::text, '{NULL_TOKEN}')"
            for attribute in attributes
        )
        + "))"
    )
    
    attribute_alias_select = ", ".join(
        f"{attribute['src']} AS {attribute['tgt']}" for attribute in attributes
    )
    attribute_target_columns = ", ".join(attribute["tgt"] for attribute in attributes)
    attribute_prefixed_select = ", ".join(
        f"source_rows.{attribute['tgt']}" for attribute in attributes
    )

    return [
        f"DROP TABLE IF EXISTS {temp_table};",
        (f"CREATE TEMP TABLE {temp_table} AS "
         f"SELECT {_hash_key_expression(business_key_column)} AS {hub_key_column}, "
         f"{hash_diff_expr} AS hash_diff, {attribute_alias_select} "
         f"FROM (SELECT {business_key_column}, load_date, {source_columns}, "
         f"row_number() OVER (PARTITION BY {business_key_column} ORDER BY load_date DESC) AS row_num "
         f"FROM {source_table} WHERE batch_id = {batch_id}) d "
         f"WHERE row_num = 1 AND {business_key_column} IS NOT NULL "
         f"DISTRIBUTED BY ({hub_key_column});"),
        (f"INSERT INTO {target_satellite} "
         f"({hub_key_column}, load_date, source_name, batch_id, hash_diff, {attribute_target_columns}) "
         f"SELECT source_rows.{hub_key_column}, timestamp '{load_timestamp}', '{SOURCE_NAME}', {batch_id}, "
         f"source_rows.hash_diff, {attribute_prefixed_select} "
         f"FROM {temp_table} source_rows "
         f"LEFT JOIN (SELECT {hub_key_column}, hash_diff FROM ("
         f"  SELECT {hub_key_column}, hash_diff, "
         f"  row_number() OVER (PARTITION BY {hub_key_column} ORDER BY load_date DESC) AS row_num "
         f"  FROM {target_satellite} "
         f"  WHERE {hub_key_column} IN (SELECT {hub_key_column} FROM {temp_table})) ranked "
         f"  WHERE row_num = 1) latest_version "
         f"ON latest_version.{hub_key_column} = source_rows.{hub_key_column} "
         f"WHERE latest_version.{hub_key_column} IS NULL "
          f"   OR latest_version.hash_diff <> source_rows.hash_diff;"),
        f"DROP TABLE IF EXISTS {temp_table};"
        f"ANALYZE {target_satellite};"
    ]


def _build_sts_sql(mapping, batch_id, load_timestamp):

    source_table = mapping["source_table"]
    target_sts = mapping["target_table"]
    business_key_column = mapping["bk_column"]
    hub_key_column = mapping["hk_column"]
    batch_id = int(batch_id)
    temp_table = _temp_table_name(source_table) + "_sts"

    return [
        f"DROP TABLE IF EXISTS {temp_table};",
        (f"CREATE TEMP TABLE {temp_table} AS "
         f"SELECT {_hash_key_expression(business_key_column)} AS {hub_key_column}, "
         f"       is_deleted "
         f"FROM (SELECT {business_key_column}, is_deleted, "
         f"             row_number() OVER (PARTITION BY {business_key_column} ORDER BY load_date DESC) AS rn "
         f"      FROM {source_table} WHERE batch_id = {batch_id} "
         f"        AND {business_key_column} IS NOT NULL) dedup "
         f"WHERE rn = 1 "
         f"DISTRIBUTED BY ({hub_key_column});"),
        (f"INSERT INTO {target_sts} "
         f"({hub_key_column}, load_date, source_name, batch_id, is_deleted) "
         f"SELECT source.{hub_key_column}, timestamp '{load_timestamp}', '{SOURCE_NAME}', {batch_id}, "
         f"       source.is_deleted "
         f"FROM {temp_table} source "
         f"LEFT JOIN (SELECT {hub_key_column}, is_deleted FROM ("
         f"  SELECT {hub_key_column}, is_deleted, "
         f"  row_number() OVER (PARTITION BY {hub_key_column} ORDER BY load_date DESC) AS rn "
         f"  FROM {target_sts} "
         f"  WHERE {hub_key_column} IN (SELECT {hub_key_column} FROM {temp_table})) ranked "
         f"  WHERE rn = 1) latest "
         f"ON latest.{hub_key_column} = source.{hub_key_column} "
         f"WHERE latest.{hub_key_column} IS NULL "
         f"   OR source.is_deleted IS DISTINCT FROM latest.is_deleted;"),
        f"DROP TABLE IF EXISTS {temp_table};"
        f"ANALYZE {target_sts};"
    ]

def execute_statements(greenplum_hook, sql_statements):
    connection = greenplum_hook.get_conn()
    try:
        with connection.cursor() as cursor:
            for statement in sql_statements:
                cursor.execute(statement)
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()

def load_phase(load_order, **airflow_context):
    from airflow.providers.postgres.hooks.postgres import PostgresHook

    greenplum_hook = PostgresHook("greenplum_default")
    batch_info = airflow_context["ti"].xcom_pull(task_ids="begin")
    batch_id = batch_info["batch_id"]
    load_timestamp = batch_info["load_timestamp"]

    mappings = fetch_mapping(greenplum_hook, load_order)
    all_statements = []
    for mapping in mappings:
        all_statements.extend(generate_sql(mapping, batch_id, load_timestamp))
    execute_statements(greenplum_hook, all_statements)
    #for mapping in mappings:
    #    sql_statements = generate_sql(mapping, batch_id, load_timestamp)
    #    execute_statements(greenplum_hook, sql_statements)
    return len(mappings)
