use strict;
use warnings;

use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 5;
}

use BookDB::Form::User;
use BookDB::Schema::DB;

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');

my $form = BookDB::Form::User->new( schema => $schema );

my $params = {
   user_name => "Joe Smith",
   occupation => "Programmer",
   'birthdate.year' => '1974',
   'birthdate.month' => 4,
   'birthdate.day' => 21,
   'address.street' => "101 Main Street",
   'address.city' => "Podunk",
   'address.state' => "New York"
};
$form->validate($params);
ok( $form->validated, 'form validates');

$form->update;
END { $form->item->delete }

is( $form->item->user_name, 'Joe Smith', 'created item');

ok( $form->item->address, 'address has been created' );

is_deeply( $form->field('address')->value,
   { street => "101 Main Street",
     city => "Podunk",
     state => "New York" }, 'value is correct' );
is_deeply( $form->fif, $params, 'fif is correct' );


