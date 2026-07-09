import os
import sys
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "utils"))
from run_tool import run_pg_tool

PG_SOURCE_CONN = "pg_source_default"


def _generate(**ctx):
    run_pg_tool(PG_SOURCE_CONN, "generator.py", ["--scale", "1"])


with DAG(
    dag_id="source_generate",
    start_date=datetime(2024, 1, 1),
    schedule=timedelta(minutes=10),
    catchup=False,
    tags=["generator", "pg"],
    default_args={"owner": "data", "retries": 0},
) as dag:
    generate = PythonOperator(
        task_id="generate", 
        python_callable=_generate
    )
