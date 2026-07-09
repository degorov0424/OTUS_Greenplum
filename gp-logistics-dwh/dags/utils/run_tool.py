
import os
import subprocess
import sys
from urllib.parse import quote

UTILS_DIR = os.path.dirname(os.path.abspath(__file__))


def pg_dsn(conn_id):
    from airflow.providers.postgres.hooks.postgres import PostgresHook
    c = PostgresHook(conn_id).get_connection(conn_id)
    host = c.host or "localhost"
    port = c.port or 5432
    user = quote(c.login or "", safe="")
    pw = quote(c.password or "", safe="")
    db = c.schema or ""
    return f"postgresql://{user}:{pw}@{host}:{port}/{db}"


def run_pg_tool(conn_id, script_name, args=None):
    args = list(args or [])
    cmd = [sys.executable, os.path.join(UTILS_DIR, script_name), *args]
    env = dict(os.environ)
    env["PG_DSN"] = pg_dsn(conn_id)
    subprocess.run(cmd, env=env, cwd=UTILS_DIR, check=True)
