use strict;
use warnings;

use Test::More;
my $tests = 16;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::MonthName';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );
my $field = $class->new(
    name    => 'test_field',
    type    => $name,
);

ok( defined $field,  'new() called' );

for ( 1 .. 12 ) {
    $field->input( $_ );
    $field->validate_field;
    ok( !$field->has_errors, $_ . ' is valid' );
}

$field->input( 0 );
$field->validate_field;
ok( $field->has_errors, '0 is not valid day of the week' );
$field->input( 13 );
$field->validate_field;
ok( $field->has_errors, '13 is not valid day of the week' );


