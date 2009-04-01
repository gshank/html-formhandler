package BookDB::Schema::DB::Author;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("author");
__PACKAGE__->add_columns(
  "last_name",
  { data_type => "VARCHAR", is_nullable => 0, size => 16 },
  "first_name",
  { data_type => "VARCHAR", is_nullable => 0, size => 16 },
  "country_iso",
  { data_type => "character", default_value => undef, is_nullable => 1, size => 2, },
  "birthdate",
  { data_type => "DATETIME", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("first_name", "last_name");
#__PACKAGE__->has_many(
#  "books",
#  "BookDB::Schema::DB::Book",
#  { "foreign.author_id" => "self.id" },
#);

__PACKAGE__->belongs_to(
  'country',
  'BookDB::Schema::DB::Country',
  { iso => 'country_iso' },
);

1;
