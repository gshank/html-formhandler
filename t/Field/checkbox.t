use strict;
use warnings;

use Test::More;
plan tests => 10;

my $class = 'HTML::FormHandler::Field::Checkbox';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );
my $field = $class->new(
    name    => 'test_field',
    type    => $name,
);

ok( defined $field,  'new() called' );

$field->input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'input 1 is 1' );

$field->input( 0 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'input 0 is 0' );


$field->input( 'checked' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 'checked', 'value is "checked"' );


$field->input( undef );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 4' );
is( $field->value, 0, 'input undef is 0' );







