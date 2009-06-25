use strict;
use warnings;
use Test::More;

BEGIN
{
   eval "use Email::Valid";
   plan skip_all => 'Email::Valid required' if $@;
   plan tests => 7;
}

my $class = 'HTML::FormHandler::Field::Email';
use_ok($class);
my $field = $class->new( name => 'test_field', );
ok( defined $field, 'new() called' );

$field->input('foo@bar.com');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 'foo@bar.com', 'value returned' );

$field->input('foo@bar');
$field->validate_field;
ok( $field->has_errors, 'Test for errors 2' );
is(
   $field->errors->[0],
   'Email should be of the format someuser@example.com',
   'Test error message'
);

$field->input('someuser@example.com');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );

