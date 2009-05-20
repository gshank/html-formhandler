use strict;
use warnings;

use Test::More;
my $tests = 7;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::IntRange';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );
my $field = $class->new(
    name    => 'test_field',
    type    => $name,
    range_start => 30,
    range_end   => 39,
);

ok( defined $field,  'new() called' );

$field->input( 30 );
$field->validate_field;
ok( !$field->has_errors, '30 in range' );

$field->input( 39 );
$field->validate_field;
ok( !$field->has_errors, '39 in range' );

$field->input( 35 );
$field->validate_field;
ok( !$field->has_errors, '35 in range' );

$field->input( 29 );
$field->validate_field;
ok( $field->has_errors, '29 out of range' );


$field->input( 40 );
$field->validate_field;
ok( $field->has_errors, '40 out of range' );

