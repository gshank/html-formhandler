use strict;
use warnings;
use Test::More;

BEGIN
{
   eval "use Email::Valid";
   plan skip_all => 'Email::Valid required' if $@;
   plan tests => 7;
}

$ENV{LANG} = 'en_us'; # in case user has LANG set

my $class = 'HTML::FormHandler::Field::Email';
use_ok($class);
my $field = $class->new( name => 'test_field', );
$field->build_result;
ok( defined $field, 'new() called' );

$field->_set_input('foo@bar.com');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 'foo@bar.com', 'value returned' );

$field->_set_input('foo@bar');
$field->validate_field;
ok( $field->has_errors, 'Test for errors 2' );
is(
   $field->errors->[0],
   'Email should be of the format someuser@example.com',
   'Test error message'
);

$field->_set_input('someuser@example.com');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'email' => (
        type => 'Email',
        email_valid_params => { -mxcheck => 1 },
    );
}

