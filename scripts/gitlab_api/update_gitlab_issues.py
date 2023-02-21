from __future__ import annotations

import requests
import os
import json
import traceback
import logging
from typing import Any

import psycopg2

from utils.models import Issue


def construct_get_issues_url(base_url: str, page: int, per_page: int = 100, with_labels_details: str = 'true'):
    return (
        f'{base_url}/api/v4/issues?scope=all&per_page={per_page}&page={page}&with_labels_details={with_labels_details}'
    )


def get_issues_from_api(base_url: str, token: str) -> list[dict[str, Any]]:
    issues: list[dict[str, Any]] = []

    get_issues_url = construct_get_issues_url(base_url=base_url, page=1)

    response = requests.get(get_issues_url, headers={'PRIVATE-TOKEN': token})
    response.raise_for_status()

    issues.extend(response.json())

    n_total_pages = int(response.headers['X-Total-Pages'])

    for i in range(2, n_total_pages + 1):
        get_issues_url = construct_get_issues_url(base_url=base_url, page=i)
        response = requests.get(get_issues_url, headers={'PRIVATE-TOKEN': token})
        response.raise_for_status()
        issues.extend(response.json())

    logging.info('Found %s issues', len(issues))

    return issues


def validate_issues(issues: list[dict[str, Any]]) -> list[Issue]:
    return [Issue(**issue) for issue in issues]


def upload_issues_to_db(pg_conn, issues: list[Issue]):
    for issue in issues:
        cur = pg_conn.cursor()
        try:
            sql = (
                "insert into issues (id, project_id, title, description, state, labels, created_at, updated_at,"
                " closed_at, due_date) values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) on conflict (id) do update set id ="
                " excluded.id, project_id = excluded.project_id, title = excluded.title, description ="
                " excluded.description, state = excluded.state, labels = excluded.labels, created_at ="
                " excluded.created_at, updated_at = excluded.updated_at"
            )
            values = (
                issue.id,
                issue.project_id,
                issue.title,
                issue.description,
                issue.state,
                json.dumps(issue.labels),
                issue.created_at,
                issue.updated_at,
                issue.closed_at,
                issue.due_date,
            )
            cur.execute(sql, values)
            pg_conn.commit()
        except Exception:
            logging.error(traceback.format_exc())
            pg_conn.rollback()
            continue


def update_issues(base_url: str, token: str, pg_conn):
    issues = get_issues_from_api(base_url, token)
    validated_issues = validate_issues(issues)
    upload_issues_to_db(pg_conn, validated_issues)


if __name__ == '__main__':
    from dotenv import load_dotenv

    load_dotenv()

    logging.getLogger().setLevel(logging.INFO)

    base_url = os.getenv('GITLAB_URL')
    if base_url is None:
        raise ValueError('Set variable GITLAB_URL in .env file to your gitlab instance url.')

    token = os.getenv('GITLAB_API_TOKEN')
    if token is None:
        raise ValueError('Set variable GITLAB_API_TOKEN in .env file to your gitlab API token.')

    with psycopg2.connect(host='localhost', port='5433', dbname='kaban_db', user='kaban', password='kaban') as pg_conn:
        update_issues(base_url=base_url, token=token, pg_conn=pg_conn)
