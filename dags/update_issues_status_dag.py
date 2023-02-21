import pendulum
from airflow.decorators import dag, task
from airflow.models import Variable
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.postgres.operators.postgres import PostgresOperator

from update_gitlab_issues import update_issues


@task
def load_issues_from_api():
    base_url = Variable.get('GITLAB_URL')
    token = Variable.get('GITLAB_API_TOKEN')

    pg_hook = PostgresHook(postgres_conn_id='KabanPostgres')

    with pg_hook.get_conn() as pg_conn:
        update_issues(base_url=base_url, token=token, pg_conn=pg_conn)


@dag(
    schedule_interval="@hourly",
    start_date=pendulum.datetime(2022, 12, 23, tz="Europe/Moscow"),
    is_paused_upon_creation=True,
    catchup=False,
    tags=["Kaban"],
)
def update_issues_status_dag():

    load_task = load_issues_from_api()

    update_issues_status_task = PostgresOperator(
        task_id='update_issues_status',
        sql='sql/update_issues_status_info.sql',
        postgres_conn_id='KabanPostgres',
    )

    update_issues_status_task.set_upstream(load_task)


update_issues_status_dag()
