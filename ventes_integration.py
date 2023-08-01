# -*- coding: utf-8 -*-
import csv
import logging
import pendulum
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from sqlalchemy import create_engine, func
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError

from ventes_class import Vente, VenteDetails, Base

logger = logging.getLogger(__name__)
database_connection_string = 'sqlite:////var/tmp/ventes_all.db'

engine = create_engine(database_connection_string, echo=True)
Session = sessionmaker(bind=engine)
session = Session()

Base.metadata.create_all(engine)


def process_csv():
    with open('/var/tmp/ventes.csv', 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            id_vente = row['id_vente']
            nom_produit = row['nom_produit']
            nom_magasin = row['nom_magasin']
            date_vente = datetime.strptime(row['date_vente'], '%Y-%m-%d')
            prix_vente = float(row['prix_vente'])

            existing_vente = session.query(Vente).filter(
                func.lower(Vente.nom_magasin) == func.lower(nom_magasin)
            ).first()

            if existing_vente:
                vente = existing_vente
            else:
                vente = Vente(nom_magasin)

            vente_detail = VenteDetails(
                id_vente=id_vente,
                nom_produit=nom_produit,
                date_vente=date_vente,
                prix_vente=prix_vente
            )
            vente.vente_details.append(vente_detail)
            session.add(vente)

            try:
                session.commit()
            except IntegrityError:
                session.rollback()
                logger.error(f"Error inserting row: {row}")


dag = DAG(
    'ventes_integration',
    description='Load CSV data into the database',
    schedule=None,
    start_date=pendulum.datetime(2023, 5, 15, tz="Europe/Paris"),
    tags=["paHpa", "ventes", "intégration", "étude", "study"]
)

csv_to_database = PythonOperator(
    task_id='process_csv',
    python_callable=process_csv,
    dag=dag,
)

csv_to_database
