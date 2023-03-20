with issue_cycle_time as (
	select
		issue_id,
		date_trunc('day', closed_at - opened_at) + '1 day'::interval as cycle_time
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
	where status_id = 6 and first_status != 6
),
cycle_time_bins as (
	select
		make_interval(days => generate_series(1, extract(day from max(cycle_time))::integer)) as cycle_time
	from
		issue_cycle_time
),
cycle_time_agg as (
	select
		cycle_time,
		count(*) as issue_count
	from
		issue_cycle_time
	group by cycle_time
)
select
	ctb.cycle_time,
	case when cta.issue_count is null then 0 else cta.issue_count end as issue_count
from
	cycle_time_bins ctb
	left join cycle_time_agg cta on ctb.cycle_time = cta.cycle_time
order by ctb.cycle_time;
