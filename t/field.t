use Test::More tests => 8;

use_ok('HTML::FormHandler::Field');

my $field = HTML::FormHandler::Field->new( name => 'somefield' );

ok( $field, 'create field');

$field = HTML::FormHandler::Field->new(
     name => 'AnotherField',
     type => 'Text',
     widget => 'select1',
     required => 1,
     required_message => 'This field is REQUIRED'
); 

ok( $field, 'more complicated field' );

ok( $field->full_name eq 'AnotherField', 'full name' );

ok( $field->id eq 'fld-AnotherField', 'field id' );

ok( $field->widget eq 'select1', 'field widget' );

$field->order(3);
ok( $field->order == 3, 'field order' );

$field->add_error('This is an error string');
ok( $field->errors, 'added error' );

