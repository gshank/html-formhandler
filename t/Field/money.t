use strict;
use warnings;

use Test::More;
my $tests = 6;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::Money';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );
my $field = $class->new(
    name    => 'test_field',
    type    => $name,
);

ok( defined $field,  'new() called' );

$field->input( $field->trim_value('   $123.45  ') );
$field->process;
ok( !$field->has_errors, 'Test for errors "   $123.00  "' );
is( $field->value, 123.45, 'Test value == 123.45' );


$field->input( $field->trim_value('   $12x3.45  ') );
$field->process;
ok( $field->has_errors, 'Test for errors "   $12x3.45  "' );
like( $field->errors->[0], qr/Argument \"12x3.45\" isn't numeric in sprintf/, 'get error' );




