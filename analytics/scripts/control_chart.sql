select
	t.closed_at as time,
	extract(day from date_trunc('day', t.closed_at - t.opened_at) + '1 day')::integer as cycle_time,
	i.title
from (
	select
		issue_id,
		status_id,
		first_value(status_id) over (partition by issue_id order by status_id) as first_status,
		min(started_at) over (partition by issue_id) as opened_at,
		max(started_at) over (partition by issue_id) as closed_at
	from
		issues_status_transition
)t
inner join issues i on t.issue_id = i.id 
where status_id = 6 and first_status != 6
order by time
