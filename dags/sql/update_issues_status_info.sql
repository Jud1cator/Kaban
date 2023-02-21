with issues_labels as (
	select
		id,
		title,
		state,
		(json_array_elements(labels)->>'id')::int as label_id
	from
		issues
),
team_issues as (
	select
		il.id, il.title, t.id as team_id
	from
		issues_labels il
		inner join team_labels tl on il.label_id = tl.id
		inner join teams t on t.label_id = tl.id
),
status_issues as (
	select
		il.id,
		case
			when il.state = 'closed' then 6
			else iss.id
		end as status_id
	from
		issues_labels il
		inner join status_labels sl on il.label_id = sl.id
		inner join issue_statuses iss on iss.label_id = sl.id
),
last_update_issue_statuses as (
	select
		t.issue_id,
		t.status_id,
		t.started_at,
		t.updated_at
	from (
		select
			*,
			row_number() over (partition by ist.issue_id order by ist.updated_at desc) as rn
		from
			issues_status_transition ist
	)t
	where rn = 1
)
insert into issues_status_transition (
	issue_id,
	team_id,
	status_id,
	started_at,
	updated_at
) 
select
	ti.id as issue_id,
	ti.team_id as team_id,
	si.status_id as status_id,
	coalesce(luis.started_at, '{{ data_interval_end }}'::timestamptz) as started_at,
	'{{ data_interval_end }}'::timestamptz as updated_at
from
	team_issues ti
	inner join status_issues si on ti.id = si.id
	left join last_update_issue_statuses luis on ti.id = luis.issue_id and si.status_id = luis.status_id
on conflict (issue_id, status_id, started_at) do update
set
	updated_at = excluded.updated_at;
