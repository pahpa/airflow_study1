# -*- coding: utf-8 -*-
import uuid
import logging
from sqlalchemy import Column, String, DateTime, Float, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

logger = logging.getLogger(__name__)
Base = declarative_base()


class Vente(Base):
    __tablename__ = 'vente'

    id = Column(Integer, primary_key=True)
    uuid = Column(String, default=str(uuid.uuid4()))
    nom_magasin = Column(String, unique=True)

    vente_details = relationship('VenteDetails', back_populates="vente")

    def __init__(self, nom_magasin):
        self.nom_magasin = nom_magasin

    def __repr__(self):
        return f"{self.id} {self.nom_magasin}"
    

class VenteDetails(Base):
    __tablename__ = 'vente_details'

    id = Column(Integer, primary_key=True)
    uuid = Column(String, default=str(uuid.uuid4()))
    vente_id = Column(Integer, ForeignKey('vente.id'))
    id_vente = Column(String)
    nom_produit = Column(String)
    date_vente = Column(DateTime)
    prix_vente = Column(Float)

    vente = relationship('Vente', back_populates='vente_details')

    def __init__(self, id_vente, nom_produit, date_vente, prix_vente):
        self.id_vente = id_vente
        self.nom_produit = nom_produit
        self.date_vente = date_vente
        self.prix_vente = prix_vente