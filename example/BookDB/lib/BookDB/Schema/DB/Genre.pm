package BookDB::Schema::DB::Genre;

use strict;
use warnings;

use base 'DBIx::Class';

BookDB::Schema::DB::Genre->load_components("Core");
BookDB::Schema::DB::Genre->table("genre");
BookDB::Schema::DB::Genre->add_columns(
  "id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
);
BookDB::Schema::DB::Genre->set_primary_key("id");
BookDB::Schema::DB::Genre->has_many(
  "books_genres",
  "BookDB::Schema::DB::BooksGenres",
  { "foreign.genre_id" => "self.id" },
);
BookDB::Schema::DB::Genre->many_to_many(
  books => 'books_genres', 'book'
);


1;
