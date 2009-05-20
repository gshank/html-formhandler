use strict;
use warnings;

use Test::More;
my $tests = 12;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::PosInteger';

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
ok( !$field->has_errors, 'Test positive' );
is( $field->value, 10, 'Test value == 10' );

$field->input( '-10' );
$field->validate_field;
ok( $field->has_errors, 'Test negative' );


$field->input( '-10.123' );
$field->validate_field;
ok( $field->has_errors, 'Test real number ' );

TODO: {
    $field->value( 123.456 );
    local $TODO = 'What if the datastore has a non integer?';
    is( $field->fif_value, '123', 'Test non-integer formatted ' );
}







