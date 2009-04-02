package BookDB::Schema::DB::Country;

# Created by DBIx::Class::Schema::Loader v0.03012 @ 2008-01-15 16:54:19

use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("country");
__PACKAGE__->add_columns(
    iso => { data_type => 'character', is_nullable => 0, size => 2 },
    name => { data_type => 'character varying', is_nullable => 1, size => 80 },
    printable_name => { data_type => 'character varying', is_nullable => 0, size => 80 },
    iso3 => { data_type => 'character', size => 3 },
    numcode => { data_type => 'integer' },
);

__PACKAGE__->set_primary_key("iso");


1;

