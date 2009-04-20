use strict;
use warnings;
use Test::More tests => 3;


my $class = 'HTML::FormHandler::Field::TextArea';

use_ok( $class );

my $field = $class->new( name => 'comments', cols => 40, rows => 3 );
ok( $field, 'get TextArea field');

$field->input("Testing, testing, testing... This is a test");

$field->process;

ok( !$field->has_errors, 'field has no errors');
