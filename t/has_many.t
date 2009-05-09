use strict;
use warnings;
use Test::More tests => 5;

use_ok( 'HTML::FormHandler::Field::HasMany' );
use_ok( 'HTML::FormHandler::Field::HasMany::Instance' );

{
   package HasMany::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'my_test';
   has_field 'addresses' => ( type => 'HasMany' );
   has_field 'addresses.street';
   has_field 'addresses.city';
   has_field 'addresses.country';

}

my $form = HasMany::Form->new;

ok( $form, 'created hasmany form');

$form = HasMany::Form->new;
ok( $form->field('addresses')->has_fields, 'created form again with fields');

my $init_object = {
   addresses => [
      {
         street => 'First Street',
         city => 'Prime City',
         country => 'Utopia',
      },
      {
         street => 'Second Street',
         city => 'Secondary City',
         country => 'Graustark',
      },
      {
         street => 'Third Street',
         city => 'Tertiary City',
         country => 'Atlantis'
      }
   ]
};

my $form = HasMany::Form->new( init_object => $init_object ); 
ok( $form, 'created form from initial object' );

# values are in right place, but need new methods for getting
# out fif and values


my $params = {
   'addresses.0.street' => 'First Street',
   'addresses.0.city' => 'Prime City',
   'addresses.0.country' => 'United States',
   'addresses.1.street' => 'Second Street',
   'addresses.1.city' => 'Secondary City',
   'addresses.1.country' => 'Graustark',
   'addresses.2.street' => 'Third Street',
   'addresses.2.city' => 'Tertiary City',
   'addresses.2.country' => 'Atlantis'
};

=cut


