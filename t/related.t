use strict;
use warnings;

use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 7;
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
$form->process($params);
END { $form->item->delete }
ok( $form->validated, 'related form validated');
$form->process($params);
ok( $form->validated, 'second pass validated');

my $user = $form->item;
is( $user->user_name, 'Joe Smith', 'created item');
is( $schema->resultset('Address')->search({ user_id => $user->id  })->count, 1,
    'the right number of addresses' );

ok( $form->item->address, 'address has been created' );

is_deeply( $form->field('address')->value,
   { street => "101 Main Street",
     city => "Podunk",
     state => "New York" }, 'value is correct' );
is_deeply( $form->fif, $params, 'fif is correct' );


