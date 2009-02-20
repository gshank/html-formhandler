BEGIN TRANSACTION;
CREATE TABLE book (
    id INTEGER PRIMARY KEY,
    isbn varchar(100),
    title varchar(100),
    author varchar(100),
    publisher varchar(100),
    pages int,
    year int,
    format int REFERENCES format,
    genre int REFERENCES genre,
    borrower int REFERENCES borrower,
    borrowed varchar(100)
);
INSERT INTO "book" VALUES(1, '0-7475-5100-6', 'Harry Potter and the Order of the Phoenix', 'J.K. Rowling', 'Boomsbury', 766, 2001, 1, 5, 1, '');
INSERT INTO "book" VALUES(2, '9 788256006199', 'Idioten', 'Fjodor Mikhajlovitsj Dostojevskij', 'Interbook', 303, 1901, 2, 3, 2, '2004-00-10');
INSERT INTO "book" VALUES(3, '434012386', 'The Confusion', 'Neal Stephenson', 'Heinemann', 345, 2002, 2, NULL, 2, '2009-01-16');
INSERT INTO "book" VALUES(4, '782128254', 'The Complete Java 2 Certification Study Guide: Programmer''s and Developers Exams (With CD-ROM)', 'Simon Roberts/Philip Heller/Michael Ernest', 'Sybex Inc', NULL, 1999, NULL, NULL, NULL, NULL);
INSERT INTO "book" VALUES(5, '123-1234-0-123', 'Winnie The Pooh', 'A.A.Milne', 'Houghton Mifflin', 345, 1935, 2, NULL, 4, '2008-11-14');
INSERT INTO "book" VALUES(6, '0-596-10092-2', 'Perl Testing: A Developer''s Notebook', 'Ian Langworth & chromatic', 'O''Reilly', 182, 2005, 3, NULL, 2, '2009-01-16');
CREATE TABLE borrower (
    id INTEGER PRIMARY KEY,
    name varchar(100),
    phone varchar(20),
    url varchar(100),
    email varchar(100)
);
INSERT INTO "borrower" VALUES(1, 'In Shelf', NULL, '', '');
INSERT INTO "borrower" VALUES(2, 'Ole Øyvind Hove', '23 23 14 97', 'http://thefeed.no/oleo', 'oleo@trenger.ro');
INSERT INTO "borrower" VALUES(3, 'John Doe', '607-222-3333', 'http://www.somewhere.com/', 'john@gmail.com');
INSERT INTO "borrower" VALUES(4, 'Mistress Muffet', '999-000-2222', NULL, 'muffet@tuffet.org');
CREATE TABLE format (
    id INTEGER PRIMARY KEY,
    name varchar(100)
);
INSERT INTO "format" VALUES(1, 'Paperback');
INSERT INTO "format" VALUES(2, 'Hardcover');
INSERT INTO "format" VALUES(3, 'Comic');
INSERT INTO "format" VALUES(4, 'Trade');
INSERT INTO "format" VALUES(5, 'Graphic Novel');
INSERT INTO "format" VALUES(6, 'E-book');
CREATE TABLE books_genres (
   book_id INTEGER REFERENCES book,
   genre_id INTEGER REFERENCES genre,
   primary key (book_id, genre_id)
);
INSERT INTO "books_genres" VALUES(1, 5);
INSERT INTO "books_genres" VALUES(1, 3);
INSERT INTO "books_genres" VALUES(2, 9);
INSERT INTO "books_genres" VALUES(5, 5);
INSERT INTO "books_genres" VALUES(3, 1);
INSERT INTO "books_genres" VALUES(6, 3);
INSERT INTO "books_genres" VALUES(6, 2);
CREATE TABLE genre (
    id INTEGER PRIMARY KEY,
    name varchar(100)
);
INSERT INTO "genre" VALUES(1, 'Sci-Fi');
INSERT INTO "genre" VALUES(2, 'Computers');
INSERT INTO "genre" VALUES(3, 'Mystery');
INSERT INTO "genre" VALUES(4, 'Historical');
INSERT INTO "genre" VALUES(5, 'Fantasy');
INSERT INTO "genre" VALUES(6, 'Technical');
CREATE TABLE author (
   first_name VARCHAR(100),
   last_name VARCHAR(100),
   country VARCHAR(100),
   birthdate DATETIME,
   CONSTRAINT name PRIMARY KEY (first_name, last_name)
);
INSERT INTO "author" VALUES ("J.K.", "Rowling", "U.K.", "2003-01-16 00:00:00" );
INSERT INTO "author" VALUES ("Fyodor", "Dostoyevsky", "Russia", "1821-11-11 00:00:00" );
INSERT INTO "author" VALUES ("Neil", "Stephenson", "United States", "1959-10-31 00:00:00" );
CREATE TABLE user (
   user_id INTEGER PRIMARY KEY,
   user_name VARCHAR(100),
   fav_cat VARCHAR(32),
   fav_book VARCHAR(32),
   occupation VARCHAR(32)
);
INSERT INTO "user" VALUES ( 1, 'jdoe', 'Sci-Fi', 'Necronomicon', 'management' );
INSERT INTO "user" VALUES ( 2, 'muffet', 'Fantasy', 'Cooking Fungi', 'none' );
INSERT INTO "user" VALUES ( 3, 'sam', 'Technical', 'Higher Order Perl', 'programmer' );
INSERT INTO "user" VALUES ( 4, 'jsw', 'Historical', 'History of the World', 'unemployed' );
INSERT INTO "user" VALUES ( 5, 'plax', 'Sci-Fi', 'Fungibility', 'editor' );

COMMIT;
