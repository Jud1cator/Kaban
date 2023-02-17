create table if not exists issues (
	id int4 primary key,
	project_id int4,
	title text,
	description text,
	state text,
	labels json,
	created_at timestamptz,
	updated_at timestamptz,
	closed_at timestamptz,
	due_date text
);

create table if not exists status_labels (
	id int4 primary key,
	name text
);

create table if not exists team_labels (
	id int4 primary_key,
	name text
);

insert into status_labels (id, name)
values
	(312, 'Selected For Dev'),
	(278, 'Blocked'),
	(270, 'In progress'),
	(279, 'Awaiting review'),
	(280, 'In review'),
on conflict do nothing;

insert into team_labels (id, name)
values
	(288, 'Active Eng'),
	(321, 'Active RnD')
on conflict do nothing;

create table if not exists daily_issue_status_counts (
	date date,
	team text,
	status text,
	issues_count int4,
	primary key (date, team, status)
);