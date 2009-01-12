use strict;
use warnings;

use Test::More;
my $tests = 15;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::Text';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );




my $field = $class->new(
    name    => 'test_field',
    type    => $name,
    form    => undef,
);



ok( defined $field,  'new() called' );

my $string = 'Some text';

$field->input( $string );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, $string, 'is value input string');

$field->input( '' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, undef, 'is value input string');

$field->required(1);
$field->validate_field;
ok( $field->has_errors, 'Test for errors 3' );

$field->input('hello');
$field->required(1);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 'hello', 'Check again' );

$field->size( 3 );
$field->validate_field;
ok( $field->has_errors, 'Test for too long' );

$field->size( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test for right length' );


$field->min_length( 10 );
$field->validate_field;
ok( $field->has_errors, 'Test not long enough' );

$field->min_length( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test just long enough' );

$field->min_length( 4 );
$field->validate_field;
ok( !$field->has_errors, 'Test plenty long enough' );

# Make sure there's an error if passed an array.
$field->size(undef);
$field->min_length(undef);
$field->input([qw/ hello there /]);
$field->validate_field;
ok( $field->has_errors, 'Passed array to non-multiple field' );
