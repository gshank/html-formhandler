use strict;
use warnings;

use Test::More;
my $tests = 7;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::Money';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );
my $field = $class->new(
    name    => 'test_field',
    type    => $name,
);

ok( defined $field,  'new() called' );

$field->input( '   $123.45  ' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors "   $123.00  "' );
is( $field->value, 123.45, 'Test value == 123.45' );
#is( $field->input, '$123.45', 'input has been trimmed' );


$field->input( '   $12x3.45  ' );
$field->validate_field;
ok( $field->has_errors, 'Test for errors "   $12x3.45  "' );
is( $field->errors->[0], 'Value cannot be converted to money', 'get error' );

$field->input( 2345 );
$field->validate_field;
is( $field->value, '2345.00', 'transformation worked: 2345 => 2345.00' );



