-- Issues are stored in the format they are received from the API
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


-- Labels which represent issue status (except for 'Closed', which does not have label)
create table if not exists status_labels (
	id int4 primary key,
	name text
);


-- Labels which represent issue belonging to specific team
create table if not exists team_labels (
	id int4 primary key,
	name text
);


-- As labels might potentially change, it is usefull to associate issues with teams which
-- reference labels
create table if not exists teams (
	id serial primary key,
	name text,
	label_id int4 references team_labels (id)
);


-- As labels might potentially change, it is usefull to associate issues with statuses which
-- reference labels
create table if not exists issue_statuses (
	id int4 primary key,
	name text,
	label_id int4 references status_labels (id)
);


-- Gitlab API does not have a way to track issues time spent in a list (status).
-- Issues can be frequently queried to update their status.
create table if not exists issues_status_transition (
	issue_id int4,
	team_id int4,
	status_id int4,
	started_at timestamptz,
	updated_at timestamptz,
	primary key (issue_id, status_id)
);


insert into team_labels (id, name)
values
	(288, 'Active Eng'),
	(321, 'Active RnD')
on conflict do nothing;


insert into status_labels (id, name)
values
	(312, 'Selected For Dev'),
	(278, 'Blocked'),
	(270, 'In progress'),
	(279, 'Awaiting review'),
	(280, 'In review')
on conflict do nothing;


insert into teams (name, label_id)
values
	('Eng', 288),
	('RnD', 321)
on conflict do nothing;


insert into issue_statuses (id, name, label_id)
values
	(1, 'Selected For Dev', 312),
	(2, 'Blocked',          278),
	(3, 'In progress',      270),
	(4, 'Awaiting review',  279),
	(5, 'In review',        280),
	(6, 'Closed',           null)
on conflict do nothing;
