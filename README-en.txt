==============================================================================
AIRFLOW SELF-TRAINING BY EXAMPLE - DOCKER VERSION (v2.0)
==============================================================================

This project allows you to deploy a complete Data stack (Airflow 2.6, Postgres 13
and FastAPI) in isolation on Ubuntu 24.04.

-----------------------------------------------------------------------
1. ARCHITECTURE AND STRUCTURE OF THE PROJECT
-----------------------------------------------------------------------

airflow-study/
├── dags/                <-- Tes scripts .py + .gitkeep
├── logs/ <-- Logs folder (ignored by git) + .gitkeep
├── plugins/             <-- Tes extensions Airflow + .gitkeep
├── config/ <-- Configuration files + .gitkeep
├── docker-compose.yaml <-- Defining services and volumes
├── Dockerfile <-- Custom image (Pandas, FastAPI...)
├── Makefile <-- Simplified control commands
├── sales.csv <-- Your data source (at the root)
└── .env <-- UID configuration (managed by Makefile)

-----------------------------------------------------------------------
2. COMMISSIONING PROCEDURE (AFTER PURGING)
-----------------------------------------------------------------------

Strictly follow this order to ensure proper operation:

STEP 1: Initializing the environment
Rebuilds the image, generates the .env and creates the database.
$ make airflow-init

STEP 2: Set system permissions (Crucial on Ubuntu)
Gives necessary write permissions to Docker containers.
$ sudo chown -R $USER:$USER . && sudo chmod -R 775 ./dags ./logs ./plugins ./config

STEP 3: Export configuration (Optional)
Generates the internal settings file if modification is necessary.
$ make config-export

STEP 4: Launch the stack and copy the data
This command prepares the files, copies "sales.csv" to /var/tmp
and starts the services.
$ make airflow-run

STEP 5: Verification
Verify that the containers are "Up" or "Healthy".
$ docker ps

-----------------------------------------------------------------------
3. ACCESS TO SERVICES
-----------------------------------------------------------------------

- Interface Airflow    : http://localhost:8080 (Login: admin / Pass: admin)
- API FastAPI (Swagger) : http://localhost:8000/docs
- Base Postgres        : localhost:5432 (User: airflow / Pass: airflow)

-----------------------------------------------------------------------
4. DATA MANAGEMENT (CSV)
-----------------------------------------------------------------------

The "sales.csv" file is automatically managed by the Makefile:
1. It must be present at the root of your project.
2. "make airflow-run" automatically copies it to /var/tmp/.
3. In your DAGs, use the path: /var/tmp/ventes.csv

-----------------------------------------------------------------------
5. DRIVING COMMANDS (MAKEFILE)
-----------------------------------------------------------------------

| Order | Action |
|-------------------|------------------------------------------------|
| make list | Shows command help |
| make airflow-init  | Setup initial (Image, DB, Admin, .env)          |
| make config-export | Generates own config/airflow.cfg file |
| make translate | Translate this file to README-en.txt |
| make airflow-run | Copy the data and start the whole stack |
| make airflow-kill | Stop containers |
| makelogs | Displays logs in real time |
| make purge | DELETE EVERYTHING (Complete cleaning before reset) |

-----------------------------------------------------------------------
6. DEPANNAGE (FAQ)
-----------------------------------------------------------------------

* "Permission Denied" ?
Re-execute STEP 2 (chown/chmod).

* The sales.csv file is not found by the DAG?
Check that it is present in /var/tmp on your Ubuntu.

* Translation ?
If you modify this file (README-fr.txt), run "make translate"
to update the English version.

-----------------------------------------------------------------------
7. CREDITS AND COLLABORATION
-----------------------------------------------------------------------

This self-study project was structured and documented with the help of
Gemini (Google AI), acting as a thought partner.
AI has contributed to:
* Dockerfile and Docker-Compose optimization.
* Creating a robust Makefile for Ubuntu 24.04.
* Implementation of Git best practices (.gitignore, .gitkeep).
* The writing and translation of this documentation.

-----------------------------------------------------------------------
End of documentation.
==============================================================================
