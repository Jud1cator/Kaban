with all_dates as (
	select
		generate_series(min(started_at), max(updated_at), '1d')::date as dt
	from
		issues_status_transition
),
issues_count as (
	select
		dt,
		status_id,
		status,
		count(*) as issues_count
	from (
		select
		  	dt,
		    ist.status_id as status_id,
		    iss.name as status,
		    row_number() over (partition by dt, issue_id order by ist.updated_at desc) as dt_last_status
	  	from
			all_dates ad
			inner join issues_status_transition ist on ist.started_at::date <= dt and ist.updated_at::date >= dt
			inner join teams t on t.id = ist.team_id
			inner join issue_statuses iss on iss.id = ist.status_id
			inner join issues i on i.id = ist.issue_id
		order by
			dt, status_id
	)t
	where
		t.dt_last_status = 1
	group by
		dt, status_id, status
)
select
  dt as time,
  status,
  sum(issues_count) over (partition by dt order by status_id desc)
from
  issues_count
