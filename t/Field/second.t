use strict;
use warnings;

use Test::More;
my $tests = 7;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::Second';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );
my $field = $class->new(
    name    => 'test_field',
    type    => $name,
    form    => undef,
);

ok( defined $field,  'new() called' );

$field->input( 0 );
$field->validate_field;
ok( !$field->has_errors, '0 in range' );

$field->input( 59 );
$field->validate_field;
ok( !$field->has_errors, '59 in range' );

$field->input( 12 );
$field->validate_field;
ok( !$field->has_errors, '12 in range' );

$field->input( -1  );
$field->validate_field;
ok( $field->has_errors, '-1 out of range' );


$field->input( 60 );
$field->validate_field;
ok( $field->has_errors, '60 out of range' );

