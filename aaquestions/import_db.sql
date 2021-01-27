DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;
PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  associated_author_id INTEGER,

  FOREIGN KEY (associated_author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  questions TEXT NOT NULL,
  users TEXT NOT NULL
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  likes INTEGER,
  author_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY(author_id) REFERENCES users(id)
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  parent_id INTEGER,
  question_id INTEGER,
  author_id INTEGER,

  FOREIGN KEY (parent_id) REFERENCES replies(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO 
  users (fname, lname)
VALUES 
  ('ryan', 'naing'),
  ('lakhte', 'agha');

INSERT INTO
  questions (title, body, associated_author_id)
VALUES
  ('what is life', 'i don''t know what life is', 
    (SELECT id FROM users WHERE fname = 'lakhte')),
  ('what?', 'what did you just say', 
    (SELECT id FROM users WHERE lname = 'naing'));

INSERT INTO
  replies (body, parent_id, author_id, question_id)
VALUES
  ('life is jokes', null, 1, 1),
  ('life is not jokes', 1, 2, 1);