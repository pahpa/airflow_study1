# -*- coding: utf-8 -*-
# flask --app mini_serv run -h 0.0.0.0 -p 8181 --debug --reload
from flask import Flask, jsonify
import sqlite3
import pandas as pd

app = Flask(__name__)


@app.route('/magasin/<nom_magasin>')
def details_magasin(nom_magasin):
    df = pd.read_csv('/var/tmp/ventes.csv')
    ventes = df[df['nom_magasin'] == nom_magasin]
    details = []
    for _, vente in ventes.iterrows():
        detail = {
            'id_vente': vente['id_vente'],
            'nom_produit': vente['nom_produit'],
            'date_vente': vente['date_vente'],
            'prix_vente': vente['prix_vente']
        }
        details.append(detail)
    return jsonify({'nom_magasin': nom_magasin, 'ventes': details})


@app.route('/sell_aggreg')
def read_sqlite_table():
    conn = sqlite3.connect('/var/tmp/ventes.db')
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM table_aggregee")
    rows = cursor.fetchall()
    column_names = [description[0] for description in cursor.description]
    conn.close()
    data = []
    for row in rows:
        row_dict = {}
        for i in range(len(column_names)):
            row_dict[column_names[i]] = row[i]
        data.append(row_dict)
    return jsonify({"data": data})

