PRAGMA foreign_keys = ON;

DROP TABLE if exists users;
DROP TABLE if exists questions;
DROP TABLE if exists question_follows;
DROP TABLE if exists replies;
DROP TABLE if exists question_likes;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL
);




CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    author_id INTEGER NOT NULL,

    FOREIGN KEY (author_id) REFERENCES users(id)
);



CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);




CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    parent_reply_id INTEGER,
    author_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    body TEXT NOT NULL,

    FOREIGN KEY (author_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);




CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    author_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (author_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
    users (fname, lname)
VALUES
    ('Alex', 'Seant'),
    ('Brian', 'Yoo'),
    ('Dennis', 'Hu'),
    ('Hasnain', 'Shamim');

INSERT INTO
    questions (title, body, author_id)
VALUES
    ('Exporting Data', 'How do I export my database to its raw sql code?', (SELECT id FROM users WHERE users.fname = 'Alex' AND users.lname = 'Seant')), --user_id = 1
    ('Where to Start Learning', 'How do I learn to use unreal engine?', (SELECT id FROM users WHERE users.fname = 'Dennis' AND users.lname = 'Hu')),    --user_id = 3
    ('Junior DBA Opportunities?', 'Anyone has any jobs for junior DBA position?', (SELECT id FROM users WHERE users.fname = 'Hasnain' AND users.lname = 'Shamim')); --user_id = 4
    
    
    
    

INSERT INTO
    replies (parent_reply_id, author_id, question_id, body)
VALUES
    (NULL, 1, 1, 'SOME BODY TEXT'),
    (NULL, (SELECT id FROM users WHERE users.fname = 'Brian' AND users.lname = 'Yoo'), (SELECT id FROM questions WHERE questions.title = 'Where to Start Learning'), 'YEAHHHHHHHHH'),
    (NULL, (SELECT id FROM users WHERE users.fname = 'Alex' AND users.lname = 'Seant'), (SELECT id FROM questions WHERE questions.title = 'Junior DBA Opportunities?'), 'I WANT TO BE A JUNIOR DBA'),
    (NULL, (SELECT id FROM users WHERE users.fname = 'Alex' AND users.lname = 'Seant'), (SELECT id FROM questions WHERE questions.title = 'Exporting Data'), 'Only do child replies one-deep'),
    (NULL, (SELECT id FROM users WHERE users.fname = 'Hasnain' AND users.lname = 'Shamim'), (SELECT id FROM questions WHERE questions.title = 'Junior DBA Opportunities?'), 'All replies to the question at any depth');
    
INSERT INTO
    replies (parent_reply_id, author_id, question_id, body)
VALUES
        (1, (SELECT id FROM users WHERE users.fname = 'Alex' AND users.lname = 'Seant'), (SELECT id FROM questions WHERE questions.title = 'Where to Start Learning'), 'Child Reply'),
    (2, (SELECT id FROM users WHERE users.fname = 'Brian' AND users.lname = 'Yoo'), (SELECT id FROM questions WHERE questions.title = 'Junior DBA Opportunities?'), 'Child Reply'),
    (3, (SELECT id FROM users WHERE users.fname = 'Hasnain' AND users.lname = 'Shamim'), (SELECT id FROM questions WHERE questions.title = 'Exporting Data'), 'OChild Reply'),
    (1, (SELECT id FROM users WHERE users.fname = 'Alex' AND users.lname = 'Seant'), (SELECT id FROM questions WHERE questions.title = 'Junior DBA Opportunities?'), 'All Child Reply');




INSERT INTO
    question_follows (question_id, user_id)
VALUES
   (2, 3),
   (1, 4),
   (3, 3),
   (3, 2),
   (1, 2),
   (1, 3);