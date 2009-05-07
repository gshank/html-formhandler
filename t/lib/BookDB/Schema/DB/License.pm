package BookDB::Schema::DB::License;


use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("licenses");
__PACKAGE__->add_columns(
    license_id => { data_type => 'INTEGER', is_nullable => 0 },
    name => { data_type => 'VARCHAR', is_nullable => 0, size => 32 },
    label => { data_type => 'VARCHAR', is_nullable => 0, size => 32 },
    active => { data_type => 'INTEGER', size => 1 },
);

__PACKAGE__->set_primary_key("license_id");
__PACKAGE__->has_many( 'user', 'BookDB::Schema::DB::User',
   { 'foreign.license_id' => 'self.license_id'},
   { cascade_delete => 0 } );


1;

