# Kaban
Kaban allows to track GitLab issue status transitions (defined by lists/labels) and collect kanban metrics. For example, you may create labels such as 'In progress', 'Awaiting review', 'Staging' and track time issue spent in each status. Up to date, there is no other way to get that time from GitLab API :)

Tools used: PostgreSQL, Airflow

## To run locally:
1. Create some directories for Airflow: `mkdir -p ./logs ./plugins`
2. Add variable for Airflow: `echo -e "AIRFLOW_UID=$(id -u)" >> .env`
3. Add variable with your gitlab instance URL: `echo -e "GITLAB_URL=https://gitlab.yourdomain.com" >> .env`
4. Add variable with your gitlab API read token: `echo -e "GITLAB_API_TOKEN=yourgitlabapireadtoken" >> .env`
5. Run all services (make sure ports 5433 and 8081 are available, otherwise change the mapping): `docker compose up -d`
6. Setup postgres connection in Airflow:
- Connection Id: KabanPostgres
- Host: gitlab-postgres
- Schema: kaban_db
- Login: kaban
- Password: kaban
- Port: 5433
7. Add `GITLAB_URL` and `GITLAB_API_TOKEN` variables to Airflow
8. Enable dag to start collecting info about issues statuses (like your manager usually does)
9. TODO: connect kaban_db to some BI tool and build some fancy project management dashboard 

## Grafana dashboard example
SQL queries for each graph are available in `analytics/scripts`
![image](https://user-images.githubusercontent.com/22914495/229174347-f8413737-89b8-41b8-8dfc-8d6ae2cff17f.png)

