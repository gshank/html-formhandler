use strict;
use warnings;
use Test::More;
use lib 't/lib';

use_ok( 'HTML::FormHandler::Field::Text' );

my $field = HTML::FormHandler::Field::Text->new(
   name => 'password',
   type => 'Text',
   required => 1,
   password => 1,
);

is( $field->password, 1, 'password is set');

$field->_set_value('abcdef');
is( $field->value, 'abcdef', 'set and get value' );

is( $field->fif, '', 'no fif for password');

$field = HTML::FormHandler::Field::Text->new(
   name => 'not_password',
   type => 'Text',
   required => 1,
);

is( $field->password, undef, 'password is not set');

$field->_set_value('abcdef');
is( $field->value, 'abcdef', 'set and get value' );

is( $field->fif, 'abcdef', 'get fif');

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
                                ne_username => 'username',
                                minlength => 6,
                              },
          ];
   }

}


my $form = My::Form->new;

$field = $form->field('password');

my $params = {
   username => 'my4username',
   password => 'something'
};

$form->process( $params );

ok( $field,  'got password field' );

$field->_set_input( '2192ab201def' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );

$field->_set_input( 'ab1' );
$field->validate_field;
ok( $field->has_errors, 'too short' );

$field->_set_input( 'my4username' );
$field->validate_field;
ok( $field->has_errors, 'matches username' );

$field->_set_input( '' );
$field->validate_field;
ok( !$field->has_errors, 'empty password accepted' );
is($field->noupdate, 1, 'noupdate has been set on password field' );

my $pass = 'my4user5name';
$field->_set_input( $pass );
$field->validate_field;
ok( !$field->has_errors, 'just right' );
is ( $field->value, $pass, 'Input and value match' );



{
   package Password::Form;

   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+field_name_space' => ( default => 'Field' );
   has_field 'password' => ( type => 'Password', required => 1 );
   has_field '_password' => ( type => 'PasswordConf', );

}

$form = Password::Form->new;
ok( $form, 'form created' );

$params = {
   password => ''
};

$form->process( params => $params );
ok( !$form->validated, 'form validated' );

ok( !$form->field('password')->noupdate, q[noupdate is 'false' on password field] );

ok( $form->field('_password')->has_errors, 'Password confirmation has errors' );

$form->process( params => { password => 'aaaaaa', _password => 'bbbb' } );
ok( $form->field('_password')->has_errors, 'Password confirmation has errors' );

$form->process( params => { password => 'aaaaaa', _password => 'aaaaaa' } );
ok( $form->validated, 'password confirmation validated' );

done_testing;
