# -*- coding: utf-8 -*-
# uvicorn mini_serv2:app --reload
from fastapi import FastAPI
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from ventes_class import Vente, VenteDetails

engine = create_engine('sqlite:////var/tmp/ventes_all.db')
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

app = FastAPI()


@app.get("/vente_details")
def get_vente_details():
    db = SessionLocal()
    
    # Retrieve all Vente instances
    ventes = db.query(Vente).all()
    
    vente_details_by_vente = {}
    
    for vente in ventes:
        # Retrieve the VenteDetails instances for each Vente
        vente_details = db.query(VenteDetails).filter(VenteDetails.id_vente == vente.id).all()
        
        # Store the VenteDetails instances in a list
        vente_details_list = []
        for vente_detail in vente_details:
            vente_details_list.append({
                "id": vente_detail.id,
                "uuid": vente_detail.uuid,
                "id_vente": vente_detail.id_vente,
                "nom_produit": vente_detail.nom_produit,
                "date_vente": vente_detail.date_vente,
                "prix_vente": vente_detail.prix_vente
            })
        
        # Store the list of VenteDetails instances for the Vente
        vente_details_by_vente[vente.nom_magasin] = vente_details_list
    
    return vente_details_by_vente
