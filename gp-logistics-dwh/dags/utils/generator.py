import argparse
import datetime as dt
import os
import random
import re
import sys
import time
from collections import defaultdict

for _stream in (sys.stdout, sys.stderr):
    if hasattr(_stream, "reconfigure"):
        _stream.reconfigure(encoding="utf-8")

try:
    from faker import Faker
except ImportError:
    sys.stderr.write("Faker не установлен. Установите: pip install -r requirements.txt\n")
    sys.exit(2)

try:
    import psycopg2
except ImportError:
    sys.stderr.write("psycopg2 не установлен. Установите: pip install -r requirements.txt\n")
    sys.exit(2)


# ------------------------------- справочники --------------------------------

TRUCK_MAKES = ["Peterbilt", "Kenworth", "Freightliner", "Volvo", "Mack", "International"]
FREIGHT_TYPES = ["Dry Van", "Refrigerated", "Flatbed", "Tanker", "Container"]
TRAILER_TYPES = ["Dry Van", "Refrigerated", "Flatbed", "Tanker", "Container"]
CUSTOMER_TYPES = ["Dedicated", "Spot", "Broker", "Contract"]
TERMINALS = ["Dallas-TX", "Phoenix-AZ", "Atlanta-GA", "Chicago-IL", "Denver-CO", "Reno-NV"]
FACILITY_TYPES = ["Cross-Dock", "Warehouse", "Distribution Center", "Terminal"]
EVENT_TYPES = ["Pickup", "Delivery"]
MAINT_TYPES = ["Inspection", "Repair", "Preventive", "Tire Replacement", "Oil Change", "Brake Service"]
INCIDENT_TYPES = ["Moving Violation", "Accident", "HOS Violation", "Inspection Violation", "Cargo Damage"]
STATUSES = ["Active", "Inactive", "Suspended"]
BOOKING_TYPES = ["Spot", "Contract"]
TRIP_STATUSES = ["Completed", "In Transit", "Delayed", "Cancelled"]
LOAD_STATUSES = ["Booked", "Dispatched", "Completed", "Cancelled"]


FILL_START = None      # дата начала диапазона заполнения (--fill-start) или None
FILL_END = None
FILL_SPAN_DAYS = 0


def _setup_fill(args):
    global FILL_START, FILL_END, FILL_SPAN_DAYS
    if getattr(args, "fill_start", None) and getattr(args, "fill_end", None):
        FILL_START = dt.date.fromisoformat(args.fill_start)
        FILL_END = dt.date.fromisoformat(args.fill_end)
        FILL_SPAN_DAYS = max((FILL_END - FILL_START).days, 1)


def _recent(rng, days_back=3):
    if FILL_START is not None:
        d = FILL_START + dt.timedelta(days=rng.randint(0, FILL_SPAN_DAYS))
        return dt.datetime.combine(d, dt.time(
            hour=rng.randint(0, 23), minute=rng.randint(0, 59), second=rng.randint(0, 59)))
    return dt.datetime.now() - dt.timedelta(
        days=rng.randint(0, days_back),
        seconds=rng.randint(0, 86400),
    )


def _recent_date(rng, days_back=3):
    return _recent(rng, days_back).date()



def gen_customer(f, rng, fks):
    return {
        "customer_name": f.company(),
        "customer_type": rng.choice(CUSTOMER_TYPES),
        "credit_terms_days": rng.choice([0, 15, 30, 45, 60]),
        "primary_freight_type": rng.choice(FREIGHT_TYPES),
        "account_status": "Active",
        "contract_start_date": f.date_between(start_date="-2y", end_date="today"),
        "annual_revenue_potential": round(rng.uniform(100_000, 2_000_000), 2),
    }


def gen_driver(f, rng, fks):
    return {
        "first_name": f.first_name(),
        "last_name": f.last_name(),
        "hire_date": f.date_between(start_date="-12y", end_date="-30d"),
        "termination_date": None,
        "license_number": f.bothify("??-######").upper(),
        "license_state": f.state_abbr(),
        "date_of_birth": f.date_between(start_date="-65y", end_date="-21y"),
        "home_terminal": rng.choice(TERMINALS),
        "employment_status": "Active",
        "cdl_class": rng.choice(["A", "B", "C"]),
        "years_experience": rng.randint(1, 30),
    }


def gen_truck(f, rng, fks):
    return {
        "unit_number": f.bothify("T-####"),
        "make": rng.choice(TRUCK_MAKES),
        "model_year": rng.randint(2015, 2024),
        "vin": f.bothify("?#?#??##??######??").upper()[:17],
        "acquisition_date": f.date_between(start_date="-8y", end_date="today"),
        "acquisition_mileage": round(rng.uniform(0, 200_000), 1),
        "fuel_type": "Diesel",
        "tank_capacity_gallons": rng.choice([100, 125, 150, 200, 240]),
        "status": "Active",
        "home_terminal": rng.choice(TERMINALS),
    }


def gen_trailer(f, rng, fks):
    return {
        "trailer_number": f.bothify("R-####"),
        "trailer_type": rng.choice(TRAILER_TYPES),
        "length_feet": rng.choice([28, 45, 48, 53]),
        "model_year": rng.randint(2015, 2024),
        "vin": f.bothify("?#?#??##??######??").upper()[:17],
        "acquisition_date": f.date_between(start_date="-8y", end_date="today"),
        "status": "Active",
        "current_location": f"{f.city()}, {f.state_abbr()}",
    }


def gen_facility(f, rng, fks):
    lat = round(rng.uniform(25.0, 49.0), 6)
    lon = round(rng.uniform(-122.0, -70.0), 6)
    return {
        "facility_name": f"{f.last_name()} {rng.choice(['Logistics','Terminal','Distribution','Warehouse'])}",
        "facility_type": rng.choice(FACILITY_TYPES),
        "city": f.city(),
        "state": f.state_abbr(),
        "latitude": lat,
        "longitude": lon,
        "dock_doors": rng.randint(4, 60),
        "operating_hours": rng.choice(["24/7", "06:00-22:00", "08:00-20:00"]),
    }


def gen_route(f, rng, fks):
    o_state = f.state_abbr()
    d_state = f.state_abbr()
    distance = round(rng.uniform(50, 2000), 2)
    return {
        "origin_city": f.city(),
        "origin_state": o_state,
        "destination_city": f.city(),
        "destination_state": d_state,
        "typical_distance_miles": distance,
        "base_rate_per_mile": round(rng.uniform(1.5, 3.5), 3),
        "fuel_surcharge_rate": round(rng.uniform(0.3, 0.8), 3),
        "typical_transit_days": rng.randint(1, 5),
    }


def gen_load(f, rng, fks):
    revenue = round(rng.uniform(800, 12_000), 2)
    fuel_surcharge = round(revenue * rng.uniform(0.08, 0.18), 2)
    accessorial = round(rng.uniform(0, 1500), 2)
    return {
        "customer_id": fks["customer_id"],
        "route_id": fks["route_id"],
        "load_date": _recent_date(rng, 3),
        "load_type": rng.choice(FREIGHT_TYPES),
        "weight_lbs": round(rng.uniform(1_000, 45_000), 2),
        "pieces": rng.randint(1, 500),
        "revenue": revenue,
        "fuel_surcharge": fuel_surcharge,
        "accessorial_charges": accessorial,
        "load_status": rng.choice(["Booked", "Dispatched", "Completed"]),
        "booking_type": rng.choice(BOOKING_TYPES),
    }


def gen_trip(f, rng, fks):
    distance = round(rng.uniform(50, 1500), 2)
    mpg = round(rng.uniform(5.5, 7.5), 2)
    gallons = round(distance / mpg, 2)
    duration = round(distance / rng.uniform(45, 60), 2)
    idle = round(rng.uniform(0, duration * 0.1), 2)
    return {
        "load_id": fks["load_id"],
        "driver_id": fks["driver_id"],
        "truck_id": fks["truck_id"],
        "trailer_id": fks["trailer_id"],
        "dispatch_date": _recent_date(rng, 3),
        "actual_distance_miles": distance,
        "actual_duration_hours": duration,
        "fuel_gallons_used": gallons,
        "average_mpg": mpg,
        "idle_time_hours": idle,
        "trip_status": rng.choice(["Completed", "In Transit", "Delayed"]),
    }


def gen_delivery_event(f, rng, fks):
    scheduled = _recent(rng, 2)
    actual = scheduled + dt.timedelta(minutes=rng.randint(-120, 240))
    return {
        "load_id": fks["load_id"],
        "trip_id": fks["trip_id"],
        "event_type": rng.choice(EVENT_TYPES),
        "facility_id": fks["facility_id"],
        "scheduled_datetime": scheduled,
        "actual_datetime": actual,
        "detention_minutes": rng.randint(0, 180),
        "on_time_flag": rng.random() > 0.2,
        "location_city": f.city(),
        "location_state": f.state_abbr(),
    }


def gen_fuel_purchase(f, rng, fks):
    gallons = round(rng.uniform(50, 250), 2)
    price = round(rng.uniform(3.8, 5.6), 3)
    return {
        "trip_id": fks["trip_id"],
        "truck_id": fks["truck_id"],
        "driver_id": fks["driver_id"],
        "purchase_date": _recent(rng, 3),
        "location_city": f.city(),
        "location_state": f.state_abbr(),
        "gallons": gallons,
        "price_per_gallon": price,
        "total_cost": round(gallons * price, 2),
        "fuel_card_number": f.bothify("FC-####-####"),
    }


def gen_maintenance(f, rng, fks):
    labor_hours = round(rng.uniform(0.5, 16), 2)
    labor_cost = round(labor_hours * rng.uniform(60, 120), 2)
    parts_cost = round(rng.uniform(0, 4000), 2)
    return {
        "truck_id": fks["truck_id"],
        "maintenance_date": _recent_date(rng, 5),
        "maintenance_type": rng.choice(MAINT_TYPES),
        "odometer_reading": round(rng.uniform(0, 500_000), 1),
        "labor_hours": labor_hours,
        "labor_cost": labor_cost,
        "parts_cost": parts_cost,
        "total_cost": round(labor_cost + parts_cost, 2),
        "facility_location": f"{f.city()}, {f.state_abbr()}",
        "downtime_hours": round(rng.uniform(0, 48), 2),
        "service_description": f.sentence(nb_words=8),
    }


def gen_incident(f, rng, fks):
    return {
        "trip_id": fks["trip_id"],
        "truck_id": fks["truck_id"],
        "driver_id": fks["driver_id"],
        "incident_date": _recent(rng, 5),
        "incident_type": rng.choice(INCIDENT_TYPES),
        "location_city": f.city(),
        "location_state": f.state_abbr(),
        "at_fault_flag": rng.random() > 0.5,
        "injury_flag": rng.random() > 0.85,
        "vehicle_damage_cost": round(rng.uniform(0, 25_000), 2),
        "cargo_damage_cost": round(rng.uniform(0, 15_000), 2),
        "claim_amount": round(rng.uniform(0, 30_000), 2),
        "preventable_flag": rng.random() > 0.6,
        "description": f.sentence(nb_words=10),
    }

TABLES = {
    "customers":          dict(bk="customer_id",         gen=gen_customer,        insert=2,
                               fks_req=[],
                               mutable={"account_status": lambda r, f: r.choice(STATUSES),
                                        "annual_revenue_potential": lambda r, f: round(r.uniform(100_000, 2_000_000), 2),
                                        "credit_terms_days": lambda r, f: r.choice([0, 15, 30, 45, 60])},
                               delete_rate=0.0002),
    "drivers":            dict(bk="driver_id",           gen=gen_driver,          insert=2,
                               fks_req=[],
                               mutable={"home_terminal": lambda r, f: r.choice(TERMINALS),
                                        "employment_status": lambda r, f: r.choice(STATUSES),
                                        "years_experience": lambda r, f: r.randint(1, 30)},
                               delete_rate=0.0002),
    "trucks":             dict(bk="truck_id",            gen=gen_truck,           insert=2,
                               fks_req=[],
                               mutable={"status": lambda r, f: r.choice(["Active", "In Repair", "Inactive"]),
                                        "home_terminal": lambda r, f: r.choice(TERMINALS),
                                        "tank_capacity_gallons": lambda r, f: r.choice([100, 125, 150, 200, 240])},
                               delete_rate=0.0002),
    "trailers":           dict(bk="trailer_id",          gen=gen_trailer,         insert=2,
                               fks_req=[],
                               mutable={"status": lambda r, f: r.choice(["Active", "In Repair", "Inactive"]),
                                        "current_location": lambda r, f: f"{f.city()}, {f.state_abbr()}"},
                               delete_rate=0.0002),
    "facilities":         dict(bk="facility_id",         gen=gen_facility,        insert=1,
                               fks_req=[],
                               mutable={"operating_hours": lambda r, f: r.choice(["24/7", "06:00-22:00", "08:00-20:00"]),
                                        "dock_doors": lambda r, f: r.randint(4, 60)},
                               delete_rate=0.0),
    "routes":             dict(bk="route_id",            gen=gen_route,           insert=1,
                               fks_req=[],
                               mutable={"base_rate_per_mile": lambda r, f: round(r.uniform(1.5, 3.5), 3),
                                        "typical_transit_days": lambda r, f: r.randint(1, 5)},
                               delete_rate=0.0),
    "loads":              dict(bk="load_id",             gen=gen_load,            insert=8,
                               fks_req=[("customer_id", "customers"), ("route_id", "routes")],
                               mutable={"load_status": lambda r, f: r.choice(LOAD_STATUSES),
                                        "revenue": lambda r, f: round(r.uniform(800, 12_000), 2),
                                        "weight_lbs": lambda r, f: round(r.uniform(1_000, 45_000), 2),
                                        "pieces": lambda r, f: r.randint(1, 500)},
                               delete_rate=0.001),
    "trips":              dict(bk="trip_id",             gen=gen_trip,            insert=10,
                               fks_req=[("load_id", "loads"), ("driver_id", "drivers"),
                                        ("truck_id", "trucks"), ("trailer_id", "trailers")],
                               mutable={"trip_status": lambda r, f: r.choice(TRIP_STATUSES),
                                        "actual_distance_miles": lambda r, f: round(r.uniform(50, 1500), 2),
                                        "fuel_gallons_used": lambda r, f: round(r.uniform(20, 300), 2),
                                        "idle_time_hours": lambda r, f: round(r.uniform(0, 10), 2)},
                               delete_rate=0.001),
    "delivery_events":    dict(bk="event_id",            gen=gen_delivery_event,  insert=12,
                               fks_req=[("load_id", "loads"), ("trip_id", "trips"), ("facility_id", "facilities")],
                               mutable={"detention_minutes": lambda r, f: r.randint(0, 180),
                                        "on_time_flag": lambda r, f: r.random() > 0.2},
                               delete_rate=0.0),
    "fuel_purchases":     dict(bk="fuel_purchase_id",    gen=gen_fuel_purchase,   insert=10,
                               fks_req=[("trip_id", "trips"), ("truck_id", "trucks"), ("driver_id", "drivers")],
                               mutable={"price_per_gallon": lambda r, f: round(r.uniform(3.8, 5.6), 3),
                                        "gallons": lambda r, f: round(r.uniform(50, 250), 2),
                                        "total_cost": lambda r, f: round(r.uniform(200, 1400), 2)},
                               delete_rate=0.0),
    "maintenance_records": dict(bk="maintenance_id",     gen=gen_maintenance,     insert=4,
                               fks_req=[("truck_id", "trucks")],
                               mutable={"labor_cost": lambda r, f: round(r.uniform(50, 2000), 2),
                                        "parts_cost": lambda r, f: round(r.uniform(0, 4000), 2),
                                        "total_cost": lambda r, f: round(r.uniform(50, 6000), 2),
                                        "downtime_hours": lambda r, f: round(r.uniform(0, 48), 2)},
                               delete_rate=0.0),
    "safety_incidents":   dict(bk="incident_id",         gen=gen_incident,        insert=2,
                               fks_req=[("trip_id", "trips"), ("truck_id", "trucks"), ("driver_id", "drivers")],
                               mutable={"claim_amount": lambda r, f: round(r.uniform(0, 30_000), 2),
                                        "vehicle_damage_cost": lambda r, f: round(r.uniform(0, 25_000), 2),
                                        "description": lambda r, f: f.sentence(nb_words=10)},
                               delete_rate=0.0),
}

INSERT_ORDER = [
    "customers", "drivers", "trucks", "trailers", "facilities", "routes",
    "loads", "trips", "delivery_events", "fuel_purchases", "maintenance_records", "safety_incidents",
]

# Только строки младше этого возраста меняются/удаляются (чтобы не двигать старые месяцы).
RECENT_WINDOW_DAYS = 60

# Колонка бизнес-даты для фильтра "недавних" кандидатов на update/soft-delete.
UPDATE_DATE_COLS = {
    "loads": "load_date", "trips": "dispatch_date", "delivery_events": "actual_datetime",
    "fuel_purchases": "purchase_date", "maintenance_records": "maintenance_date",
    "safety_incidents": "incident_date",
    "customers": "created_at", "drivers": "created_at", "trucks": "created_at",
    "trailers": "created_at", "facilities": "created_at", "routes": "created_at",
}


def detect_id_state(max_id, default_prefix, default_width=6):
    """(prefix, next_num, width) по MAX(bk); для пустой таблицы — дефолт."""
    if max_id:
        m = re.match(r"^(.*?)(\d+)$", str(max_id))
        if m:
            prefix, num, width = m.group(1), int(m.group(2)), len(m.group(2))
            return [prefix, num + 1, width]
    return [default_prefix, 1, default_width]


def format_id(state):
    prefix, num, width = state
    return f"{prefix}{str(num).zfill(width)}"


def next_id(state):
    bid = format_id(state)
    state[1] += 1
    return bid


def connect(dsn):
    if not dsn:
        sys.stderr.write("DSN не задан. Используйте --dsn или переменную PG_DSN/DATABASE_URL.\n")
        sys.exit(2)
    return psycopg2.connect(dsn)


def fetch_pool(conn, schema, table, bk, limit=200_000):
    with conn.cursor() as cur:
        cur.execute(f'SELECT "{bk}" FROM {schema}.{table} ORDER BY "{bk}" LIMIT %s', (limit,))
        return [r[0] for r in cur.fetchall()]


def fetch_max_id(conn, schema, table, bk):
    with conn.cursor() as cur:
        cur.execute(f'SELECT max("{bk}") FROM {schema}.{table}')
        return cur.fetchone()[0]


def insert_row(conn, schema, table, bk_col, bk_value, cols_vals):
    cols = [bk_col] + list(cols_vals.keys()) + ["created_at", "updated_at"]
    placeholders = ", ".join(["%s"] * (len(cols) - 2)) + ", now(), now()"
    vals = [bk_value] + list(cols_vals.values())
    sql = f'INSERT INTO {schema}.{table} ({", ".join(cols)}) VALUES ({placeholders}) RETURNING "{bk_col}"'
    with conn.cursor() as cur:
        cur.execute(sql, vals)
        return cur.fetchone()[0]


def update_one(conn, schema, table, bk_col, bk_value, col, value):
    sql = f'UPDATE {schema}.{table} SET "{col}" = %s, updated_at = now() WHERE "{bk_col}" = %s'
    with conn.cursor() as cur:
        cur.execute(sql, (value, bk_value))


def active_ids(conn, schema, table, bk_col, status_col, dead_value):
    sql = (f'SELECT "{bk_col}" FROM {schema}.{table} '
           f'WHERE "{status_col}" IS DISTINCT FROM %s')
    with conn.cursor() as cur:
        cur.execute(sql, (dead_value,))
        return [r[0] for r in cur.fetchall()]


def sample_fks(rng, pools, fks_req):
    fks = {}
    for col, src in fks_req:
        pool = pools.get(src) or []
        if not pool:
            return None 
        fks[col] = rng.choice(pool)
    return fks

def run_tick(conn, args, fake, rng, quiet=False):
    schema = args.schema
    only = set(args.only.split(",")) if args.only else None

    pools = {}
    id_states = {}
    for t, cfg in TABLES.items():
        if only and t not in only:
            continue
        pools[t] = fetch_pool(conn, schema, t, cfg["bk"])
        max_id = fetch_max_id(conn, schema, t, cfg["bk"]) or (pools[t][-1] if pools[t] else None)
        default_prefix = f"{t[:3].upper()}-"
        id_states[t] = detect_id_state(max_id, default_prefix)


    cutoff = (dt.datetime.now() - dt.timedelta(days=RECENT_WINDOW_DAYS)).strftime("%Y-%m-%d")
    recent_pools = {}
    for t, cfg in TABLES.items():
        if only and t not in only:
            continue
        date_col = UPDATE_DATE_COLS.get(t, "created_at")
        with conn.cursor() as cur:
            cur.execute(
                f'SELECT "{cfg["bk"]}" FROM {schema}.{t} WHERE "{date_col}" >= %s LIMIT 200000',
                (cutoff,),
            )
            recent_pools[t] = [r[0] for r in cur.fetchall()]

    stats = {"insert": defaultdict(int), "update": defaultdict(int), "delete": defaultdict(int)}

    def log(msg):
        if not quiet:
            print(msg)


    for t in INSERT_ORDER:
        if only and t not in only:
            continue
        cfg = TABLES[t]
        n = max(0, round(cfg["insert"] * args.scale))
        inserted = 0
        for _ in range(n):
            fks = sample_fks(rng, pools, cfg["fks_req"])
            if fks is None and cfg["fks_req"]:
                continue  
            row = cfg["gen"](fake, rng, fks if fks is not None else {})
            bid = next_id(id_states[t])
            if args.dry_run:
                inserted += 1
                pools[t].append(bid)
                continue
            bid = insert_row(conn, schema, t, cfg["bk"], bid, row)
            pools[t].append(bid)
            inserted += 1
        stats["insert"][t] = inserted


    for t, cfg in TABLES.items():
        if only and t not in only:
            continue
        rp = recent_pools.get(t, [])
        if not cfg.get("mutable") or not rp:
            continue
        k = min(args.max_per_table, int(len(rp) * args.updates))
        if k <= 0:
            continue
        chosen = rng.sample(rp, k)
        cols = list(cfg["mutable"].keys())
        for bid in chosen:
            n_cols = rng.randint(1, min(2, len(cols)))
            for col in rng.sample(cols, n_cols):
                val = cfg["mutable"][col](rng, fake)
                if args.dry_run:
                    continue
                update_one(conn, schema, t, cfg["bk"], bid, col, val)
        stats["update"][t] = k


    for t, cfg in TABLES.items():
        if only and t not in only:
            continue
        rate = cfg.get("delete_rate", 0.0)
        if rate <= 0:
            continue
        rp = recent_pools.get(t, [])
        if not rp:
            continue

        if not args.dry_run:
            with conn.cursor() as cur:
                cur.execute(f'SELECT "{cfg["bk"]}" FROM {schema}.{t} WHERE is_deleted IS NULL AND "{cfg["bk"]}" = ANY(%s)', (rp,))
                active = [r[0] for r in cur.fetchall()]
        else:
            active = rp
        k = min(args.max_per_table, int(len(active) * rate))
        if k <= 0:
            continue
        chosen = rng.sample(active, k)
        for bid in chosen:
            if args.dry_run:
                continue
            update_one(conn, schema, t, cfg["bk"], bid, "is_deleted", "Y")
        stats["delete"][t] = k

    if not args.dry_run:
        conn.commit()

    total_i = sum(stats["insert"].values())
    total_u = sum(stats["update"].values())
    total_d = sum(stats["delete"].values())
    log(f"[tick] insert={total_i} update={total_u} soft-delete={total_d} "
        f"({'dry-run' if args.dry_run else 'committed'})")
    for t in INSERT_ORDER:
        if only and t not in only:
            continue
        i, u, d = stats["insert"][t], stats["update"][t], stats["delete"][t]
        if i or u or d:
            log(f"   {t:22} +{i:<4} ~{u:<4} -{d}")
    return stats


def parse_args(argv=None
    p = argparse.ArgumentParser(description="Генератор изменений в источнике PostgreSQL")
    p.add_argument("--dsn", default=os.environ.get("PG_DSN") or os.environ.get("DATABASE_URL"),
                   help="libpq DSN или переменная PG_DSN/DATABASE_URL")
    p.add_argument("--schema", default="public")
    p.add_argument("--scale", type=float, default=1.0, help="Множитель числа вставок (default: 1.0)")
    p.add_argument("--updates", type=float, default=0.005, help="Доля обновляемых строк в таблице (default: 0.005)")
    p.add_argument("--deletes", type=float, default=0.001, help="Доля soft-delete в таблице (default: 0.001)")
    p.add_argument("--max-per-table", type=int, default=50, help="Капа изменений одного типа на таблицу за тик")
    p.add_argument("--seed", type=int, default=None, help="Seed для воспроизводимости")
    p.add_argument("--only", help="Только эти таблицы (через запятую)")
    p.add_argument("--loop", action="store_true", help="Непрерывный режим")
    p.add_argument("--interval", type=float, default=30.0, help="Пауза между тиками в --loop (сек)")
    p.add_argument("--dry-run", action="store_true", help="Показать план без записи в БД")
    p.add_argument("--fill-start", default=None, help="Начало диапазона заполнения (YYYY-MM-DD)")
    p.add_argument("--fill-end", default=None, help="Конец диапазона заполнения (YYYY-MM-DD)")
    return p.parse_args(argv)


def make_faker(seed):
    fake = Faker()
    if seed is not None:
        Faker.seed(seed)
        fake.seed_instance(seed)
    return fake


def main(argv=None):
    args = parse_args(argv)
    if args.only:
        unknown = set(args.only.split(",")) - set(TABLES)
        if unknown:
            sys.stderr.write(f"Неизвестные таблицы в --only: {sorted(unknown)}\n")
            sys.exit(2)

    _setup_fill(args)
    if FILL_START is not None:
        print(f"[fill] бизнес-даты: {FILL_START} .. {FILL_END} ({FILL_SPAN_DAYS + 1} дней)")
    rng = random.Random(args.seed)
    fake = make_faker(args.seed)
    conn = connect(args.dsn)
    try:
        if args.loop:
            print(f"[loop] интервал {args.interval}s, scale={args.scale}, Ctrl-C для остановки")
            while True:
                try:
                    run_tick(conn, args, fake, rng)
                except Exception as exc:
                    conn.rollback()
                    sys.stderr.write(f"[!] тик провален (rollback): {exc}\n")
                time.sleep(args.interval)
        else:
            run_tick(conn, args, fake, rng)
            return 0
    except KeyboardInterrupt:
        print("\n[stop] остановлено пользователем")
        return 0
    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())
