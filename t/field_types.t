use strict;
use warnings;
use Test::More;

use HTML::FormHandler::Types (':all');
use HTML::FormHandler::Field::Text;

my $field = HTML::FormHandler::Field::Text->new( name => 'test',
   apply => [ Collapse ]
);

ok( $field, 'field with Collapse' );
$field->input('This  is  a   test');
$field->validate_field;
is( $field->value, 'This is a test');

$field = HTML::FormHandler::Field::Text->new( name => 'test',
   apply => [ Upper ]
);
ok( $field, 'field with Upper' );
$field->input('This is a test');
$field->validate_field;
is( $field->value, 'THIS IS A TEST');

$field = HTML::FormHandler::Field::Text->new( name => 'test',
   apply => [ Lower ]
);
ok( $field, 'field with Lower' );
$field->input('This Is a Test');
$field->validate_field;
is( $field->value, 'this is a test');

$field = HTML::FormHandler::Field::Text->new( name => 'test',
   trim => undef,
   apply => [ Trim ]
);
ok( $field, 'field with Trim' );
$field->input('  This is a test   ');
$field->validate_field;
is( $field->value, 'This is a test');

done_testing;

