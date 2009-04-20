use strict;
use warnings;

use Test::More;
my $tests = 10;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::Multiple';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );
my $field = $class->new(
    name    => 'test_field',
    type    => $name,
);

$field->options([
    { value => 1, label => 'one' },
    { value => 2, label => 'two' },
    { value => 3, label => 'three' },
]);

ok( defined $field,  'new() called' );

$field->input( 1 );
$field->process;
ok( !$field->has_errors, 'Test for errors 1' );
# Hum, should this be an array?
is( $field->value, 1, 'Test true == 1' );

$field->input( [1] );
$field->process;
ok( !$field->has_errors, 'Test for errors 2' );
ok( eq_array( $field->value, [1], 'test array' ), 'Check [1]');

$field->input( [1,2] );
$field->process;
ok( !$field->has_errors, 'Test for errors 3' );
ok( eq_array( $field->value, [1,2], 'test array' ), 'Check [1,2]');


$field->input( [1,2,4] );
$field->process;
ok( $field->has_errors, 'Test for errors 4' );
is( $field->errors->[0], "'4' is not a valid value", 'Error message' );
