use strict;
use warnings;

use Test::More;
my $tests = 7;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::MonthDay';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );
my $field = $class->new(
    name    => 'test_field',
    type    => $name,
);

ok( defined $field,  'new() called' );

$field->input( 1 );
$field->validate_field;
ok( !$field->has_errors, '1 in range' );

$field->input( 31 );
$field->validate_field;
ok( !$field->has_errors, '31 in range' );

$field->input( 12 );
$field->validate_field;
ok( !$field->has_errors, '12 in range' );

$field->input( 0  );
$field->validate_field;
ok( $field->has_errors, '0 out of range' );


$field->input( 32 );
$field->validate_field;
ok( $field->has_errors, '32 out of range' );

