package BookDB::Schema::DB::Borrower;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("borrower");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "phone",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 100 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "books",
  "BookDB::Schema::DB::Book",
  { "foreign.borrower" => "self.id" },
);


1;
