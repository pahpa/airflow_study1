.PHONY: list

PID_FILES := $(wildcard ~/airflow/*.pid)
PIDS := $(foreach pid_file,$(PID_FILES),$(shell cat $(pid_file)))

list:
	@awk -F: '!/(list|PID*)/ && /^[A-z]/ {print $$1}' Makefile

clean:
	@find . -type d -name __pycache__ -exec rm -r {} \+
	@find . -type d -name .pytest_cache -exec rm -r {} \+
	@pip freeze | xargs pip uninstall -y

airflow-init:
	airflow db init
	airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin

airflow-data:
	mkdir -p ~/airflow/dags
	cp selling_aggreg.py ~/airflow/dags
	cp vente*.py ~/airflow/dags
	cp ventes.csv /var/tmp

airflow-run: airflow-kill airflow-data
	airflow webserver --port 8080 -D
	airflow scheduler -D

airflow-kill:
	@for pid in $(PIDS); do \
		kill -TERM "$$pid" || true; \
	done
	@rm -f $(PID_FILES)

install:
	@pip install -r requirements.txt

install-dev:
	@pip install -r requirements-dev.txt

