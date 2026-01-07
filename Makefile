.PHONY: list help clean airflow-init airflow-data airflow-run airflow-kill purge logs shell config-export translate copy-data

# Variables
DC=docker-compose
PROJECT_NAME=airflow-study
DATA_FILE=ventes.csv
DEST_PATH=/var/tmp

list: ## Liste les commandes disponibles
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup-env: ## Configure l'UID pour Docker (indispensable sur Ubuntu)
	@echo "AIRFLOW_UID=$(shell id -u)" > .env

airflow-init: setup-env ## Initialise la DB Docker, crée l'image et l'admin
	$(DC) build
	$(DC) run --rm airflow-webserver airflow db init
	$(DC) run --rm airflow-webserver airflow users create \
		--username admin --firstname admin --lastname admin \
		--role Admin --email admin@example.com --password admin

airflow-data: ## Prépare la structure des dossiers et les fichiers .gitkeep
	mkdir -p ./dags ./logs ./plugins ./config
	touch ./dags/.gitkeep ./logs/.gitkeep ./plugins/.gitkeep ./config/.gitkeep
	@echo "Structure des dossiers et .gitkeep prêts."

copy-data: ## Copie le fichier ventes.csv vers /var/tmp (requis pour les DAGs)
	@if [ -f $(DATA_FILE) ]; then \
		cp $(DATA_FILE) $(DEST_PATH)/$(DATA_FILE); \
		chmod 644 $(DEST_PATH)/$(DATA_FILE); \
		echo "Fichier $(DATA_FILE) copié vers $(DEST_PATH)."; \
	else \
		echo "Erreur : $(DATA_FILE) introuvable dans le dossier actuel."; \
	fi

config-export: airflow-data ## Exporte la configuration Airflow propre dans ./config/airflow.cfg
	$(DC) run --rm airflow-webserver airflow config list --color off > ./config/airflow.cfg
	@echo "Configuration exportée dans ./config/airflow.cfg"

translate: ## Traduit la doc de FR vers EN (nécessite translate-shell)
	@command -v trans >/dev/null 2>&1 || { echo >&2 "Erreur: 'translate-shell' n'est pas installé. Faites: sudo apt install translate-shell"; exit 1; }
	trans -b :fr :en -i README-fr.txt -o README-en.txt
	@echo "Traduction terminée : README-en.txt généré."

airflow-run: airflow-data copy-data ## Lance l'environnement Airflow complet (v2.0)
	$(DC) up -d
	@echo "Airflow est disponible sur http://localhost:8080"

airflow-kill: ## Arrête les conteneurs (sans supprimer les données)
	$(DC) down

logs: ## Voir les logs des conteneurs en temps réel
	$(DC) logs -f

shell: ## Accéder au terminal du conteneur Webserver
	$(DC) exec airflow-webserver bash

clean: ## Arrête les conteneurs et nettoie les fichiers temporaires Python
	$(DC) down
	@find . -type d -name __pycache__ -exec rm -r {} \+
	@echo "Nettoyage simple effectué."

purge: ## [DANGER] Suppression totale (sauf tes fichiers dags et config)
	$(DC) down --volumes --rmi all --remove-orphans
	docker system prune -a --volumes -f
	@echo "Système Docker entièrement purgé."
	