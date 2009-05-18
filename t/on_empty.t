use strict;
use warnings;
use Test::More tests => 5;

use lib 't/lib';

use_ok('HTML::FormHandler');
use_ok('Field::Password');

{
   package Password::Form;

   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+field_name_space' => ( default => 'Field' );
   has_field 'password' => ( type => '+Password', noupdate_if_empty => 1 );

}

my $form = Password::Form->new;
ok( $form, 'form created' );

my $params = {
   password => ''
};

$form->process( params => $params );
ok( $form->validated, 'form validated' );

is( $form->field('password')->noupdate, 1, 'noupdate has been set on password field' );

