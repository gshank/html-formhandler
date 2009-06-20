use strict;
use warnings;
use Test::More tests => 3;

{
   package Repeatable::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'my_test';
   has_field 'addresses' => ( type => 'Repeatable', auto_id => 1 );
   has_field 'addresses.street';
   has_field 'addresses.city';
   has_field 'addresses.country';

   sub validate_addresses_city
   {
      my ( $self, $field ) = @_;
      $field->add_error("Invalid City: " . $field->value) 
         if( $field->value !~ /City/ );
   }
}

my $init_object = {
   my_test => 'repeatable_errors',
   addresses => [
      {
         street => 'First Street',
         city => 'Prime',
         country => 'Utopia',
         id => 0,
      },
      {
         street => 'Second Street',
         city => 'Secondary',
         country => 'Graustark',
         id => 1,
      },
      {
         street => 'Third Street',
         city => 'Tertiary City',
         country => 'Atlantis',
         id => 2,
      }
   ]
};

my $form = Repeatable::Form->new;
ok( $form, 'form created');
$form->process( $init_object );
ok( !$form->validated, 'form did not validate' );
is( $form->num_errors, 2, 'form has two errors' );


