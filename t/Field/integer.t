use strict;
use warnings;

use Test::More;
my $tests = 21;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::Integer';

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
is( $field->value, 1, 'Test value == 1' );

$field->input( 0 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'Test value == 0' );


$field->input( 'checked' );
$field->validate_field;
ok( $field->has_errors, 'Test non integer' );


$field->input( '+10' );
$field->validate_field;
ok( !$field->has_errors, 'Test postive' );
is( $field->value, 10, 'Test value == 10' );

$field->input( '-10' );
$field->validate_field;
ok( !$field->has_errors, 'Test postive' );
is( $field->value, -10, 'Test value == -10' );


$field->input( '-10.123' );
$field->validate_field;
ok( $field->has_errors, 'Test real number' );

$field->range_start( 10 );
$field->input( 9 );
$field->validate_field;
ok( $field->has_errors, 'Test 9 < 10 fails' );

$field->input( 100 );
$field->validate_field;
ok( !$field->has_errors, 'Test 100 > 10 passes ' );

$field->range_end( 20 );
$field->input( 100 );
$field->validate_field;
ok( $field->has_errors, 'Test 10 <= 100 <= 20 fails' );

$field->range_end( 20 );
$field->input( 15 );
$field->validate_field;
ok( !$field->has_errors, 'Test 10 <= 15 <= 20 passes' );

$field->input( 10 );
$field->validate_field;
ok( !$field->has_errors, 'Test 10 <= 10 <= 20 passes' );

$field->input( 20 );
$field->validate_field;
ok( !$field->has_errors, 'Test 10 <= 20 <= 20 passes' );

$field->input( 21 );
$field->validate_field;
ok( $field->has_errors, 'Test 10 <= 21 <= 20 fails' );

$field->input( 9 );
$field->validate_field;
ok( $field->has_errors, 'Test 10 <= 9 <= 20 fails' );

TODO: {
    $field->value( 123.456 );
    local $TODO = 'What if the datastore has a non integer?';
    is( $field->fif_value, '123', 'Test non-integer formatted ' );
}












1;

