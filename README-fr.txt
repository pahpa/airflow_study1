=======================================================================
   AUTOFORMATION AIRFLOW PAR L'EXEMPLE - VERSION DOCKER (v2.0)
=======================================================================

Ce projet permet de déployer une stack Data complète (Airflow 2.6, Postgres 13 
et FastAPI) de manière isolée sur Ubuntu 24.04.

-----------------------------------------------------------------------
1. ARCHITECTURE ET STRUCTURE DU PROJET
-----------------------------------------------------------------------

airflow-study/
├── dags/                <-- Tes scripts .py + .gitkeep
├── logs/                <-- Dossier des logs (ignoré par git) + .gitkeep
├── plugins/             <-- Tes extensions Airflow + .gitkeep
├── config/              <-- Fichiers de configuration + .gitkeep
├── docker-compose.yaml  <-- Définition des services et volumes
├── Dockerfile           <-- Image personnalisée (Pandas, FastAPI...)
├── Makefile             <-- Commandes simplifiées de pilotage
├── ventes.csv           <-- Ta source de données (à la racine)
└── .env                 <-- Configuration UID (géré par Makefile)

-----------------------------------------------------------------------
2. PROCEDURE DE MISE EN SERVICE (APRES UN PURGE)
-----------------------------------------------------------------------

Suivre scrupuleusement cet ordre pour garantir le bon fonctionnement :

ÉTAPE 1 : Initialisation de l'environnement
   Reconstruit l'image, génère le .env et crée la base de données.
   $ make airflow-init

ÉTAPE 2 : Fixer les permissions système (Crucial sur Ubuntu)
   Donne les droits d'écriture nécessaires aux conteneurs Docker.
   $ sudo chown -R $USER:$USER . && sudo chmod -R 775 ./dags ./logs ./plugins ./config

ÉTAPE 3 : Exporter la configuration (Optionnel)
   Génère le fichier de paramétrage interne si besoin de modification.
   $ make config-export

ÉTAPE 4 : Lancer la stack et copier les données
   Cette commande prépare les dossiers, copie "ventes.csv" dans /var/tmp 
   et démarre les services.
   $ make airflow-run

ÉTAPE 5 : Vérification
   Vérifiez que les conteneurs sont "Up" ou "Healthy".
   $ docker ps

-----------------------------------------------------------------------
3. ACCÈS AUX SERVICES
-----------------------------------------------------------------------

- Interface Airflow    : http://localhost:8080 (Login: admin / Pass: admin)
- API FastAPI (Swagger) : http://localhost:8000/docs
- Base Postgres        : localhost:5432 (User: airflow / Pass: airflow)

-----------------------------------------------------------------------
4. GESTION DES DONNÉES (CSV)
-----------------------------------------------------------------------

Le fichier "ventes.csv" est géré automatiquement par le Makefile :
1. Il doit être présent à la racine de votre projet.
2. "make airflow-run" le copie automatiquement dans /var/tmp/.
3. Dans vos DAGs, utilisez le chemin : /var/tmp/ventes.csv

-----------------------------------------------------------------------
5. COMMANDES DE PILOTAGE (MAKEFILE)
-----------------------------------------------------------------------

| Commande           | Action                                          |
|--------------------|-------------------------------------------------|
| make list          | Affiche l'aide des commandes                    |
| make airflow-init  | Setup initial (Image, DB, Admin, .env)          |
| make config-export | Génère le fichier config/airflow.cfg propre     |
| make translate     | Traduit ce fichier en README-en.txt             |
| make airflow-run   | Copie les data et démarre toute la stack        |
| make airflow-kill  | Arrête les conteneurs                           |
| make logs          | Affiche les logs en temps réel                  |
| make purge         | SUPPRIME TOUT (Nettoyage complet avant reset)   |

-----------------------------------------------------------------------
6. DÉPANNAGE (FAQ)
-----------------------------------------------------------------------

* "Permission Denied" ? 
  Ré-exécutez l'ÉTAPE 2 (chown/chmod).

* Le fichier ventes.csv n'est pas trouvé par le DAG ?
  Vérifiez qu'il est bien présent dans /var/tmp sur votre Ubuntu.

* Traduction ?
  Si vous modifiez ce fichier (README-fr.txt), lancez "make translate" 
  pour mettre à jour la version anglaise.

-----------------------------------------------------------------------
7. CRÉDITS ET COLLABORATION
-----------------------------------------------------------------------

Ce projet d'autoformation a été structuré et documenté avec l'aide de 
Gemini (Google AI), agissant en tant que partenaire de réflexion. 
L'IA a contribué à :
* L'optimisation du Dockerfile et du Docker-Compose.
* La création d'un Makefile robuste pour Ubuntu 24.04.
* La mise en place des bonnes pratiques Git (.gitignore, .gitkeep).
* La rédaction et la traduction de la présente documentation.

-----------------------------------------------------------------------
Fin de la documentation.
=======================================================================