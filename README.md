# Kaban

Kaban is an ETL tool for GitLab issues: it tracks time which issues spend in particular status defined by labels and saves that info in local database, because there is no other way to get that time from GitLab API :)

## To run locally:
1. Create some directories for Airflow: `mkdir -p ./logs ./plugins`
2. Add variable for Airflow: `echo -e "AIRFLOW_UID=$(id -u)" >> .env`
3. Add variable with your gitlab instance URL: `echo -e "GITLAB_URL=https://gitlab.yourdomain.com" >> .env`
4. Add variable with your gitlab API read token: `echo -e "GITLAB_API_TOKEN=yourgitlabapireadtoken" >> .env`
5. Run all services (make sure ports 5433 and 8081 are available, otherwise change the mapping): `docker compose up -d`
6. Setup postgres connection in Airflow:
- host: gitlab-postgres
- port: 5433
- schema: kaban_db
- user: kaban
- password: kaban
7. Add `GITLAB_URL` and `GITLAB_API_TOKEN` variables to Airflow
8. Enable dag to start collecting info about issues statuses (like your manager usually does)
9. TODO: connect kaban_db to some BI tool and build some fancy project management dashboard 
