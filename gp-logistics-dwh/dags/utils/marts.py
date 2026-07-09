from datetime import date, timedelta

from airflow.providers.postgres.hooks.postgres import PostgresHook

GP_CONN = "greenplum_default"

FILL_MARTS = [
    "fill_dm_driver_performance",
    "fill_dm_truck_utilization",
    "fill_dm_route_profitability",
    "fill_dm_customer_analysis",
    "fill_dm_trip_facts",
    "fill_dm_delivery_performance",
    "fill_dm_safety_summary",
    "fill_dm_fleet_kpi",
]


def month_start(d):
    if isinstance(d, str):
        d = date.fromisoformat(d)
    return date(d.year, d.month, 1)


def last_day_of_month(d):
    if isinstance(d, str):
        d = date.fromisoformat(d)
    first_next = date(d.year + 1, 1, 1) if d.month == 12 else date(d.year, d.month + 1, 1)
    return first_next - timedelta(days=1)


def months_between(d_from, d_to):
    d_from = date.fromisoformat(d_from) if isinstance(d_from, str) else month_start(d_from)
    d_to = date.fromisoformat(d_to) if isinstance(d_to, str) else d_to
    out, cur = [], month_start(d_from)
    end = month_start(d_to)
    while cur <= end:
        out.append(cur.isoformat())
        cur = date(cur.year + 1, 1) if cur.month == 12 else date(cur.year, cur.month + 1, 1)
    return out

