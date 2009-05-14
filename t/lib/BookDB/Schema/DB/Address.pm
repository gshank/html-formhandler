package BookDB::Schema::DB::Address;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("address");
__PACKAGE__->add_columns(
  "address_id",
  { data_type => "INTEGER", is_nullable => 0, size => 8 },
  "user_id",
  { data_type => "INTEGER", is_nullable => 0, size => 8 },
  "street",
  { data_type => "VARCHAR", is_nullable => 0, size => 32 },
  "city",
  { data_type => "VARCHAR", is_nullable => 0, size => 32 },
  "country_iso",
  { data_type => "character", default_value => undef, is_nullable => 1, size => 2, },
);
__PACKAGE__->set_primary_key("address_id");

__PACKAGE__->belongs_to(
    'user',
    'BookDB::Schema::DB::User',
    { user_id => 'user_id' },
);

__PACKAGE__->belongs_to(
    'country',
    'BookDB::Schema::DB::Country',
    { iso => 'country_iso' },
);

1;
