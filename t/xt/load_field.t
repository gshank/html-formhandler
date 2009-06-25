use Test::More tests => 6;
use lib 't/lib';


{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   # this form specifies the form name
   #sub init_field_name_space { 'BookDB::Form::Field' }
   has '+field_name_space' => ( default => 'BookDB::Form::Field' );

   has_field 'field_one'   => ( type => '+AltText', another_attribute => 'one' );
   has_field 'field_two'   => ( type => '+AltText', another_attribute => 'two' );
   has_field 'field_three' => ( type => '+AltText', another_attribute => 'three' );

}

my $form = My::Form->new; 
ok( $form, 'get form' );

my $params = {
   field_one => 'one two three four',
   field_two => 'one three four',
   field_three => 'one three four',
};

$form->process( $params );

ok( !$form->validated, 'form validated' );

ok( !$form->field('field_one')->has_errors, 'field one has no error');

is( $form->field('field_two')->has_errors, 1, 'field two has one error');
is( $form->field('field_two')->errors->[0], 
   'Fails AltText validation', 'get error message' );

ok( !$form->field('field_three')->has_errors, 'field three has no error');

