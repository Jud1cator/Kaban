with team_issues as (
	select t.id, t.label_id, tl.name as label_name
	from (
		select
			id,
			(json_array_elements(labels)->>'id')::int as label_id
		from issues i
	)t
	inner join team_labels tl on t.label_id = tl.id
),
closed_issues as (
	select ti.id
	from
		team_issues ti
		inner join issues i2 on ti.id = i2.id
	where i2.closed_at is not null
)
select * from closed_issues