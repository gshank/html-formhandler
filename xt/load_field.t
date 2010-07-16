use strict;
use warnings;
use Test::More;
use lib 't/lib';


{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   # this form specifies the form name
   has '+field_name_space' => ( default => 'Field' );

   has_field 'field_one'   => ( type => '+AltText', another_attribute => 'one' );
   has_field 'field_two'   => ( type => '+AltText', another_attribute => 'two' );
   has_field 'field_three' => ( type => '+AltText', another_attribute => 'three' );
   has_field 'field_four'  => ( type => 'AltText',  another_attribute => 'four' );

}

my $form = My::Form->new; 
ok( $form, 'get form' );

my $params = {
   field_one => 'one two three four',
   field_two => 'one three four',
   field_three => 'one three four',
   field_four => 'four',
};

$form->process( $params );

ok( !$form->validated, 'form validated' );

ok( !$form->field('field_one')->has_errors, 'field one has no error');

is( $form->field('field_two')->has_errors, 1, 'field two has one error');
is( $form->field('field_two')->errors->[0], 
   'Fails AltText validation', 'get error message' );

ok( !$form->field('field_three')->has_errors, 'field three has no error');
ok( !$form->field('field_four')->has_errors, 'field four has no error');

{
    package Field::Text;
    use Moose;
    extends 'HTML::FormHandler::Field::Text';
    has 'my_attr' => ( is => 'rw' );
}

{
   package Test::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   # this form specifies the form name
   has '+field_name_space' => ( default => sub { ['Test', 'Field', 'FieldX']} );

   has_field 'field_text'   => ( type => '+Text', my_attr => 'test' );

}

$form = Test::Form->new;
is( $form->field('field_text')->my_attr, 'test', 'finds right field' );

done_testing;
