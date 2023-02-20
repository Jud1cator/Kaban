import pendulum
from airflow.decorators import dag


@dag(
    schedule_interval="@hourly",
    start_date=pendulum.datetime(2022, 12, 23, tz="Europe/Moscow"),
    is_paused_upon_creation=True,
    catchup=False,
    tags=["gitlab"],
)
def update_issues_status_dag():
    pass


update_issues_status_dag()
