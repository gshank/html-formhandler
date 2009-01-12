BEGIN TRANSACTION;
CREATE table book (
    id INTEGER PRIMARY KEY,
    isbn varchar(100),
    title varchar(100),
    author varchar(100),
    publisher varchar(100),
    pages int,
    year int,
    format int REFERENCES format,
    borrower int REFERENCES borrower,
    borrowed varchar(100)
);
INSERT INTO book VALUES(1, '0-7475-5100-6', 'Harry Potter and the Order of the Phoenix',
   'J.K. Rowling','Boomsbury',766,
   2001,1,1,'');

INSERT INTO book VALUES(2,'9 788256006199','Idioten',
   'Fjodor Mikhajlovitsj Dostojevskij','Interbook',303,
   1901,2,2,'2004-01-10');

INSERT INTO book VALUES(3, '0434012386','The Confusion',
   'Neal Stephenson','Heinemann', 342,
   1999,2,2,'2008-12-01');

INSERT INTO book VALUES(4,'0782128254','The Complete Java 2 Certification Study Guide',
   'Simon Roberts/Philip Heller/Michael Ernest','Sybex Inc',NULL,
   1999,1,2,'2007-05-07');
CREATE TABLE borrower (
    id INTEGER PRIMARY KEY,
    name varchar(100),
    phone varchar(20),
    url varchar(100),
    email varchar(100)
);
INSERT INTO borrower VALUES(1,'In Shelf',NULL,'','');
INSERT INTO borrower VALUES(2,'Ole Øyvind Hove','23 23 14 97','http://thefeed.no/oleo','oleo@trenger.ro');

CREATE TABLE format (
    id INTEGER PRIMARY KEY,
    name varchar(100)
);
INSERT INTO format VALUES(1,'Paperback');
INSERT INTO format VALUES(2,'Hardcover');
INSERT INTO format VALUES(3,'Comic');

CREATE TABLE books_genres (
   book_id INTEGER REFERENCES book,
   genre_id INTEGER REFERENCES genre,
   primary key (book_id, genre_id)
);

INSERT INTO books_genres VALUES(1, 5);
INSERT INTO books_genres VALUES(1, 3);
INSERT INTO books_genres VALUES(2, 4);
INSERT into books_genres VALUES(3, 5); 
INSERT into books_genres VALUES(3, 1); 

CREATE TABLE genre (
    id INTEGER PRIMARY KEY,
    name varchar(100)
);

INSERT INTO genre VALUES(1,'Sci-Fi');
INSERT INTO genre VALUES(2,'Computers');
INSERT INTO genre VALUES(3,'Mystery');
INSERT INTO genre VALUES(4,'Historical');
INSERT INTO genre VALUES(5,'Fantasy');
COMMIT;
