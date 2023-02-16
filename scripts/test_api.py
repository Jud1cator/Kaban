# ATTENTION: THIS CODE WAS WRITTEN JUST FOR QUICK TESTS, NO PRODUCTION USE INTENDED
import requests
import os
import json

import psycopg2

from dotenv import load_dotenv
load_dotenv()


url = os.getenv('URL')
token = os.getenv('TOKEN')

issues = []

response = requests.get(url + '/api/v4/issues?per_page=100&page=1&with_labels_details=true', headers={'PRIVATE-TOKEN': token})
response.raise_for_status()

issues.extend(response.json())

n_total_pages = int(response.headers['X-Total-Pages'])

for i in range(2, n_total_pages + 2):
    response = requests.get(url + f'/api/v4/issues?per_page=100&page={i}&with_labels_details=true', headers={'PRIVATE-TOKEN': token})
    response.raise_for_status()
    issues.extend(response.json())

hostname = 'localhost'
port = '5432'
username = 'kaban'
password = 'kaban'
database = 'kaban_db'

fields = ('id', 'project_id', 'title', 'description', 'state', 'labels', 'created_at', 'updated_at', 'closed_at', 'due_date')

with psycopg2.connect(host=hostname, port=port, user=username, password=password, dbname=database) as conn:
    cur = conn.cursor()
    for issue_data in issues:
        try:
            sql = "INSERT INTO issues (id, project_id, title, description, state, labels, created_at, updated_at, closed_at, due_date) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
            values = [json.dumps(issue_data[k]) if type(issue_data[k]) is list else issue_data[k] for k in fields]
            cur.execute(sql, values)
            conn.commit()
        except Exception as e:
            continue
