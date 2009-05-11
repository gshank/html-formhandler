package BookDB::Schema::DB::Employer;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("employer");
__PACKAGE__->add_columns(
  "employer_id",
  { data_type => "INTEGER", is_nullable => 0, size => 8 },
  "user_id",
  { data_type => "INTEGER", is_nullable => 0, size => 8 },
  "name",
  { data_type => "VARCHAR", is_nullable => 0, size => 32 },
  "category",
  "country",
  { data_type => "VARCHAR", is_nullable => 0, size => 32 },
);
__PACKAGE__->set_primary_key("employer_id");

__PACKAGE__->belongs_to(
    'user',
    'BookDB::Schema::DB::User',
    { user_id => 'user_id' },
);


1;
