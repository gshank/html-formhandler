package BookDB::Schema::DB::BooksGenres;

use strict;
use warnings;

use base 'DBIx::Class';

BookDB::Schema::DB::BooksGenres->load_components("Core");
BookDB::Schema::DB::BooksGenres->table("books_genres");
BookDB::Schema::DB::BooksGenres->add_columns(
  "book_id",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "genre_id",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
);
BookDB::Schema::DB::BooksGenres->set_primary_key(('book_id', 'genre_id'));
   
BookDB::Schema::DB::BooksGenres->belongs_to(
  "book",
  "BookDB::Schema::DB::Book",
  { id => "book_id" },
);
BookDB::Schema::DB::BooksGenres->belongs_to(
  "genre",
  "BookDB::Schema::DB::Genre",
  { id => "genre_id" },
);


1;
