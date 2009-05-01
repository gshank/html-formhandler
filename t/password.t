use strict;
use warnings;
use Test::More  tests => 9;
use lib 't/lib';

use_ok( 'HTML::FormHandler::Field::Text' );

my $field = HTML::FormHandler::Field::Text->new(
   name => 'password',
   type => 'Text',
   required => 1,
   password => 1,
);

is( $field->password, 1, 'password is set');

$field->value('abcdef');
is( $field->value, 'abcdef', 'set and get value' );

is( $field->fif, undef, 'no fif for password');

$field = HTML::FormHandler::Field::Text->new(
   name => 'not_password',
   type => 'Text',
   required => 1,
);

is( $field->password, undef, 'password is not set');

$field->value('abcdef');
is( $field->value, 'abcdef', 'set and get value' );

is( $field->fif, 'abcdef', 'get fif');

$field->value(undef);
is( $field->fif, undef, 'get undef fif' );

$field->input('xyz');
is( $field->fif, 'xyz', 'get fif from input');
