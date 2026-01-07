.PHONY: list clean airflow-init airflow-data airflow-run airflow-kill purge logs shell config-export translate copy-data fix-perms

# Variables
DC=docker-compose
PROJECT_NAME=airflow-study
DATA_FILE=ventes.csv
DEST_PATH=/var/tmp

list: ## Liste les commandes disponibles
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup-env: ## Configure l'UID pour Docker (indispensable sur Ubuntu)
	@echo "AIRFLOW_UID=$(shell id -u)" > .env

fix-perms: ## Fixe les permissions des dossiers (nécessite sudo)
	@echo "Réglage des permissions pour l'utilisateur $(shell whoami)..."
	sudo chown -R $(shell id -u):$(shell id -g) .
	sudo chmod -R 775 ./dags ./logs ./plugins ./config
	@echo "Permissions réglées avec succès."

airflow-data: ## Prépare la structure des dossiers et les fichiers .gitkeep
	mkdir -p ./dags ./logs ./plugins ./config
	touch ./dags/.gitkeep ./logs/.gitkeep ./plugins/.gitkeep
	@echo "Structure des dossiers prête."

airflow-init: setup-env airflow-data ## Setup complet : Build + DB + Admin + Permissions
	$(DC) build
	$(DC) run --rm airflow-webserver airflow db init
	$(DC) run --rm airflow-webserver airflow users create \
		--username admin --firstname admin --lastname admin \
		--role Admin --email admin@example.com --password admin
	$(MAKE) fix-perms

copy-data: ## Copie le fichier ventes.csv vers /var/tmp
	@if [ -f $(DATA_FILE) ]; then \
		cp $(DATA_FILE) $(DEST_PATH)/$(DATA_FILE); \
		chmod 644 $(DEST_PATH)/$(DATA_FILE); \
		echo "Fichier $(DATA_FILE) copié vers $(DEST_PATH)."; \
	else \
		echo "Attention : $(DATA_FILE) introuvable, ignorez si déjà présent dans $(DEST_PATH)."; \
	fi

airflow-run: airflow-data copy-data ## Lance Airflow + Flask + FastAPI
	$(DC) up -d
	@echo "Stack démarrée :"
	@echo "- Airflow : http://localhost:8080"
	@echo "- FastAPI : http://localhost:8000/docs"
	@echo "- Flask   : http://localhost:8181/magasin/Magasin_A"

config-export: ## Exporte la configuration Airflow vers ./config/airflow.cfg
	$(DC) run --rm airflow-webserver airflow config list --color off > ./config/airflow.cfg

translate: ## Traduit la doc FR -> EN
	@command -v trans >/dev/null 2>&1 || { echo >&2 "Installez translate-shell : sudo apt install translate-shell"; exit 1; }
	trans -b :fr :en -i README-fr.txt -o README-en.txt

airflow-kill: ## Arrête les conteneurs
	$(DC) down

logs: ## Logs en temps réel
	$(DC) logs -f

shell: ## Terminal du conteneur Webserver
	$(DC) exec airflow-webserver bash

clean: ## Nettoyage des caches Python et arrêt simple
	$(DC) down
	@find . -type d -name __pycache__ -exec rm -r {} \+

purge: ## [DANGER] Suppression totale (Volumes, Images, DB)
	$(DC) down --volumes --rmi all --remove-orphans
	docker system prune -a --volumes -f
	@echo "Système entièrement purgé."
