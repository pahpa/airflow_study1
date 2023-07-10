# -*- coding: utf-8 -*-
import pendulum

import pandas as pd
import sqlite3

from airflow import DAG
from airflow.operators.python import PythonOperator

import logging

logger = logging.getLogger(__name__)

with DAG(
    dag_id="selling_aggreg",
    default_args={"retries": 2},
    description="paHpa Selling Aggregation DAG",
    schedule='* * * * *',
    start_date=pendulum.datetime(2023, 5, 15, tz="Europe/Paris"),
    catchup=False,
    tags=["paHpa", "selling", "aggregate", "study"]
) as dag:

    def extract(**kwargs):
        ti = kwargs["ti"]
        file_path = kwargs["file_path"]
        df = pd.read_csv(file_path,
                         header=1,
                         names=['id_vente',
                                'nom_produit',
                                'nom_magasin',
                                'date_vente',
                                'prix_vente']
                         )
        logger.info(df)
        ti.xcom_push("order_data", df)

    def transform(**kwargs):
        ti = kwargs["ti"]
        df = ti.xcom_pull(task_ids="extract", key="order_data")

        aggregee = df.groupby(["nom_magasin",
                               "nom_produit"]
                              )["prix_vente"].mean().reset_index()
        ti.xcom_push(key='aggregee', value=aggregee)

    def load(**kwargs):
        ti = kwargs["ti"]
        db_path = kwargs["db_path"]
        aggregee = ti.xcom_pull(key='aggregee')
        conn = sqlite3.connect(db_path)
        aggregee.to_sql('table_aggregee', conn, if_exists='replace')
        conn.close()

    extract_task = PythonOperator(
        task_id="extract",
        python_callable=extract,
        op_kwargs={'file_path': '/var/tmp/ventes.csv'},
    )

    transform_task = PythonOperator(
        task_id="transform",
        python_callable=transform,
    )

    load_task = PythonOperator(
        task_id="load",
        python_callable=load,
        op_kwargs={'db_path': '/var/tmp/ventes.db'},
    )

    extract_task >> transform_task >> load_task

    logger.info(f"DAG ID: {dag}")
