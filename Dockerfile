FROM apache/airflow:2.6.0-python3.10

# On reste en utilisateur airflow (par défaut dans l'image)
USER airflow

# On met à jour pip pour l'utilisateur airflow uniquement
RUN pip install --no-cache-dir --user --upgrade pip

# Installation de ta stack avec les contraintes
RUN pip install --no-cache-dir --user \
    "apache-airflow[kubernetes]==2.6.0" \
    "pydantic<2" \
    "pandas" \
    "pyarrow" \
    "fastapi" \
    "uvicorn" \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.6.0/constraints-3.10.txt"