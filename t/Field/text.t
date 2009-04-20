use strict;
use warnings;

use Test::More;
my $tests = 14;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::Text';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );

my $field = $class->new(
    name    => 'test_field',
    type    => $name,
);

ok( defined $field,  'new() called' );

my $string = 'Some text';

$field->input( $string );
$field->process;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, $string, 'is value input string');

$field->input( '' );
$field->process;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, undef, 'is value input string');

$field->required(1);
$field->process;
ok( $field->has_errors, 'Test for errors 3' );

$field->input('hello');
$field->required(1);
$field->process;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 'hello', 'Check again' );

$field->size( 3 );
$field->process;
ok( $field->has_errors, 'Test for too long' );

$field->size( 5 );
$field->process;
ok( !$field->has_errors, 'Test for right length' );


$field->min_length( 10 );
$field->process;
ok( $field->has_errors, 'Test not long enough' );

$field->min_length( 5 );
$field->process;
ok( !$field->has_errors, 'Test just long enough' );

$field->min_length( 4 );
$field->process;
ok( !$field->has_errors, 'Test plenty long enough' );

