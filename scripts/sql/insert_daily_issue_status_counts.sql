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
		il.id, il.title, t.name as team
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
		end as status_id,
		case
			when il.state = 'closed' then 'Closed'
			else iss.name
		end as status
	from
		issues_labels il
		inner join status_labels sl on il.label_id = sl.id
		inner join issue_statuses iss on iss.label_id = sl.id
)
select
	ti.id, ti.title, ti.team, si.status, si.status_id
from
	team_issues ti
	inner join status_issues si on ti.id = si.id
order by team, si.status_id