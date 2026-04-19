from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import requests


def fetch_and_load_api():
    url = "https://open.er-api.com/v6/latest/USD"
    response = requests.get(url)
    data = response.json()
    
    if data.get('result') == 'success':
        rates = data['rates']
        records = [
            ('USD', 'EUR', rates.get('EUR')),
            ('USD', 'GBP', rates.get('GBP')),
            ('USD', 'UAH', rates.get('UAH'))
        ]
        
        pg_hook = PostgresHook(postgres_conn_id='postgres_default')
        pg_hook.run("TRUNCATE TABLE bronze.api_exchange_rates")
        pg_hook.insert_rows(
            table='bronze.api_exchange_rates',
            rows=records,
            target_fields=['base_currency', 'target_currency', 'rate']
        )
    else:
        raise Exception("API error")


default_args = {
    'owner': 'airflow',
    'start_date': datetime(2026, 4, 19),  
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='initial_data_load_v2', # Змінюємо ID, щоб Airflow точно створив новий запис
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False
) as dag:


    load_bronze_csv = PostgresOperator(
        task_id='load_bronze_layer',
        postgres_conn_id='postgres_default',
        sql="CALL bronze.load_bronze();"
    )

 
    load_api_rates = PythonOperator(
        task_id='load_api_rates',
        python_callable=fetch_and_load_api
    )

 
    load_silver = PostgresOperator(
        task_id='load_silver_layer',
        postgres_conn_id='postgres_default',
        sql="CALL silver.load_silver();"
    )

  
    [load_bronze_csv, load_api_rates] >> load_silver