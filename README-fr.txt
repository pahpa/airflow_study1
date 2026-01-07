=======================================================================
   AUTOFORMATION AIRFLOW PAR L'EXEMPLE - VERSION DOCKER (v2.2)
=======================================================================

Ce projet permet de déployer une stack Data complète (Airflow 2.6, Postgres 13,
FastAPI, Flask et un Dashboard Homer) de manière isolée sur Ubuntu 24.04.

-----------------------------------------------------------------------
1. ARCHITECTURE ET STRUCTURE DU PROJET
-----------------------------------------------------------------------

airflow-study/
├── dags/                <-- Tes scripts DAGs Airflow (.py)
├── logs/                <-- Logs d'exécution (gérés par Docker)
├── plugins/             <-- Extensions Airflow éventuelles
├── config/              <-- Configuration (Homer config.yml + airflow.cfg)
├── docker-compose.yaml  <-- Orchestration des 6 services
├── Dockerfile           <-- Image unifiée (Airflow + Flask + FastAPI)
├── Makefile             <-- Pilotage simplifié de la stack
├── mini_serv.py         <-- Serveur Flask (Reporting /var/tmp/ventes.csv)
├── mini_serv2.py        <-- Serveur FastAPI (Interface ORM / SQL)
├── ventes_class.py      <-- Modèles de données (SQLAlchemy)
├── ventes.csv           <-- Source de données brute (standardisée _)
└── .env                 <-- Variable UID utilisateur (auto-géré)

-----------------------------------------------------------------------
2. PROCEDURE DE MISE EN SERVICE (APRES UN PURGE)
-----------------------------------------------------------------------

ÉTAPE 1 : Initialisation complète
    Prépare l'image, initialise la base de données, crée l'utilisateur 
    admin et règle automatiquement les permissions système.
    $ make airflow-init
    (Note : Votre mot de passe sudo sera demandé pour le fix des permissions)

ÉTAPE 2 : Lancement de la stack
    Démarre tous les services en arrière-plan et synchronise les données.
    $ make airflow-run

ÉTAPE 3 : Vérification
    Vérifiez que les 6 conteneurs sont actifs (homer inclus).
    $ docker ps

-----------------------------------------------------------------------
3. ACCÈS AUX SERVICES ET APIs
-----------------------------------------------------------------------

>>> PORTAIL CENTRAL : http://localhost (Dashboard Homer) <<<

Le dashboard regroupe les accès vers :
- Interface Airflow     : http://localhost:8080 (admin / admin)
- API Flask (Reporting) : http://localhost:8181/magasin/Magasin_A
- API FastAPI (Backend) : http://localhost:8000/docs (Swagger UI)
- Base Postgres         : localhost:5432 (airflow / airflow)

-----------------------------------------------------------------------
4. SERVICES DE DONNÉES ET DASHBOARD
-----------------------------------------------------------------------

A. Dashboard Homer (Port 80) :
   - Rôle : Point d'entrée unique pour naviguer dans la stack.
   - Config : Géré via config/config.yml.

B. Serveur Flask (Port 8181) :
   - Rôle : Lecture directe du fichier CSV via Pandas.
   - Source : Lit /var/tmp/ventes.csv.

C. Serveur FastAPI (Port 8000) :
   - Rôle : Interface moderne utilisant un ORM (SQLAlchemy).
   - Source : Base SQLite générée par Airflow dans /var/tmp/.

-----------------------------------------------------------------------
5. GESTION DES DONNÉES
-----------------------------------------------------------------------

1. Le fichier "ventes.csv" à la racine utilise des underscores (Magasin_A).
2. "make airflow-run" le copie automatiquement dans /var/tmp/.
3. Le dossier /var/tmp est partagé entre l'hôte et tous les conteneurs.

-----------------------------------------------------------------------
6. COMMANDES DE PILOTAGE (MAKEFILE)
-----------------------------------------------------------------------

| Commande        | Action                                          |
|-----------------|-------------------------------------------------|
| make list       | Aide sur les commandes disponibles              |
| make airflow-init| Setup complet (Image, DB, Admin, Perms)         |
| make airflow-run | Démarre toute la stack et copie les data        |
| make fix-perms   | Répare manuellement les droits sur les dossiers |
| make logs        | Affiche les logs en temps réel                  |
| make purge       | NETTOYAGE TOTAL (Supprime images et volumes)    |

-----------------------------------------------------------------------
7. CRÉDITS ET COLLABORATION
-----------------------------------------------------------------------

Ce projet d'autoformation a été structuré et documenté avec l'aide de 
Gemini (Google AI). L'IA a contribué à l'orchestration multi-services, 
la mise en place du dashboard et la standardisation des APIs.

-----------------------------------------------------------------------
Fin de la documentation.
=======================================================================
