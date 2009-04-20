use strict;
use warnings;

use Test::More;
my $tests = 5;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::Year';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );
my $field = $class->new(
    name    => 'test_field',
    type    => $name,
);



ok( defined $field,  'new() called' );

$field->input( 0 );
$field->process;
ok( $field->has_errors, '0 is bad year' );

$field->input( (localtime)[5] + 1900 );
$field->process;
ok ( !$field->has_errors, 'Now is just a fine year' );


$field->input( 2100 );
$field->process;
ok( $field->has_errors, '2100 makes the author really old' );

