use strict;
use warnings;

use Test::More tests => 12;


use HTML::FormHandler;
use_ok( 'HTML::FormHandler::Field::Password' );

{
   package My::Form;

   use Moose;
   extends 'HTML::FormHandler';

   sub field_list {
       return [ 
               login       => 'Text',
               username    => 'Text',
               password    => { type => 'Password',
                                ne_username => 'username' },
          ];
   }

}


my $form = My::Form->new;

my $field = $form->field('password');

my $params = {
   username => 'my4username',
   password => 'something'
};

$form->process( $params );

ok( $field,  'got password field' );

$field->input( '2192ab201def' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );

$field->input( 'ab1' );
$field->validate_field;
ok( $field->has_errors, 'too short' );

$field->input( 'my4username' );
$field->validate_field;
ok( $field->has_errors, 'matches username' );

$field->input( '' );
$field->validate_field;
ok( !$field->has_errors, 'empty password accepted' );
is($field->noupdate, 1, 'noupdate has been set on password field' );

my $pass = 'my4user5name';
$field->input( $pass );
$field->validate_field;
ok( !$field->has_errors, 'just right' );
is ( $field->value, $pass, 'Input and value match' );



{
   package Password::Form;

   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+field_name_space' => ( default => 'Field' );
   has_field 'password' => ( type => 'Password', required => 1 );

}

$form = Password::Form->new;
ok( $form, 'form created' );

$params = {
   password => ''
};

$form->process( params => $params );
ok( !$form->validated, 'form validated' );

ok( !$form->field('password')->noupdate, q[noupdate is 'false' on password field] );



