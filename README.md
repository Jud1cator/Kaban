# Kaban

Kaban is an ETL tool for GitLab issues.

## To run locally:
1. `mkdir -p ./logs ./plugins`
2. `echo -e "AIRFLOW_UID=$(id -u)" > .env`
3. `docker compose up -d`
