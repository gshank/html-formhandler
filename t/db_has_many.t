use strict;
use warnings;

use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 9;
}

use BookDB::Schema::DB;

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
my $user = $schema->resultset('User')->find(1);

{
   package HasMany::Form::User;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Model::DBIC';

   has_field 'user_name';
   has_field 'occupation';

   has_field 'addresses' => ( type => 'HasMany' );
   has_field 'addresses.address_id' => ( type => 'PrimaryKey' );
   has_field 'addresses.street';
   has_field 'addresses.city';
   has_field 'addresses.country';

}

my $form = HasMany::Form::User->new;
ok( $form, 'get db has many form');

$form->process( item => $user, params => {} );

my $fif = {
   'addresses.0.city' => 'Middle City',
   'addresses.0.country' => 'Graustark',
   'addresses.0.address_id' => 1,
   'addresses.0.street' => '101 Main St',
   'addresses.1.city' => 'DownTown',
   'addresses.1.country' => 'Utopia',
   'addresses.1.address_id' => 2,
   'addresses.1.street' => '99 Elm St',
   'addresses.2.city' => 'Santa Lola',
   'addresses.2.country' => 'Grand Fenwick',
   'addresses.2.address_id' => 3,
   'addresses.2.street' => '1023 Side Ave',
   'occupation' => 'management',
   'user_name' => 'jdoe',
};
my $values = {
   addresses => [
      {
         city => 'Middle City',
         country => 'Graustark',
         address_id => 1,
         street => '101 Main St',
      },
      {
         city => 'DownTown',
         country => 'Utopia',
         address_id => 2,
         street => '99 Elm St',
      },
      {
         city => 'Santa Lola',
         country => 'Grand Fenwick',
         address_id => 3,
         street => '1023 Side Ave',
      },
   ],
   'occupation' => 'management',
   'user_name' => 'jdoe',
};

is_deeply( $form->fif, $fif, 'fill in form is correct' );
is_deeply( $form->values,  $values, 'values are correct' );

my $params = {
   user_name => "Joe Smith",
   occupation => "Programmer",
   'addresses.0.street' => "999 Main Street",
   'addresses.0.city' => "Podunk",
   'addresses.0.country' => "Utopia",
   'addresses.0.address_id' => "1",
   'addresses.1.street' => "333 Valencia Street",
   'addresses.1.city' => "San Franciso",
   'addresses.1.country' => "Utopia",
   'addresses.1.address_id' => "2",
   'addresses.2.street' => "1101 Maple Street",
   'addresses.2.city' => "Smallville",
   'addresses.2.country' => "Atlantis",
   'addresses.2.address_id' => "3"
};
$form->process($params);

ok( $form->validated, 'has_many form validated');
$form->process($params);
ok( $form->validated, 'second pass validated');

$user = $form->item;
is( $user->user_name, 'Joe Smith', 'created item');
is( $schema->resultset('Address')->search({ user_id => $user->id  })->count, 3,
    'the right number of addresses' );

is_deeply( $form->fif, $params, 'fif is correct' );

$form->process($fif);
is( $form->item->search_related( 'addresses', {city => 'Middle City'} )->first->country, 'Graustark', 'updated addresses');

