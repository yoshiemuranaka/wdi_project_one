CREATE TABLE categories(
	id serial primary key,
	name varchar(255),
	description text,
	upvote integer,
	downvote integer
);

CREATE TABLE posts(
	id serial primary key,
	cat_name varchar(255),
	title varchar(255),
	content text,
	image_url text,
	upvote integer,
	downvote integer,
	created_at DATENOW,
	expiration boolean,
	exp_date date,
);