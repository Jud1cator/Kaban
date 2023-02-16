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