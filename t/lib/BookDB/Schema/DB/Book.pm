package BookDB::Schema::DB::Book;

use Moose;

use base 'DBIx::Class';

# following attribute is non useful, since it does
# nothing that persists, but shows how you could
# do something more complicated
has 'comment' => ( isa => 'Str|Undef', is => 'rw',
  trigger => \&set_extra );

sub set_extra
{
   my ($self, $value) = @_;
   $self->extra($value);
}


BookDB::Schema::DB::Book->load_components("Core");
BookDB::Schema::DB::Book->table("book");
BookDB::Schema::DB::Book->add_columns(
  "id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "isbn",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "author",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "publisher",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "pages",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "year",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "format",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "borrower",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "borrowed",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "owner",
  {
    data_type => "INTEGER",
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "extra",
  { data_type => "varchar", is_nullable => 0, size => 100 },
);
BookDB::Schema::DB::Book->set_primary_key("id");
BookDB::Schema::DB::Book->belongs_to(
  "format",
  "BookDB::Schema::DB::Format",
  { id => "format" },
);
BookDB::Schema::DB::Book->belongs_to(
  "borrower",
  "BookDB::Schema::DB::Borrower",
  { id => "borrower" },
);
BookDB::Schema::DB::Book->belongs_to(
  "owner",
  "BookDB::Schema::DB::User",
  { user_id => "owner" },
);
BookDB::Schema::DB::Book->has_many(
  "books_genres",
  "BookDB::Schema::DB::BooksGenres",
  { "foreign.book_id" => "self.id" },
);
BookDB::Schema::DB::Book->many_to_many(
  genres => 'books_genres', 'genre'
);

1;
