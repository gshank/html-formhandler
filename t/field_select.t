use Test::More tests => 3;

use_ok( 'HTML::FormHandler::Field::Select' );

my $select_field = HTML::FormHandler::Field::Select->new(name => 'MySelect', type => 'Select' );
ok( $select_field, 'new select field' );

$select_field->value('Testing');
$select_field->options([{value => 'Testing', label => 'This is the label for Testing'}, {value => 'Again', label => 'This is the label for Again'}] );
ok( $select_field->as_label eq 'This is the label for Testing', 'field as label' ); 

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'testform_' );
   sub field_list {
       return  [
            fruit       => 'Select',
            optname     => {
               temp => 'Second'
            }
       ];
   }
   sub options_fruit {
       return (
           1   => 'apples',
           2   => 'oranges',
           3   => 'kiwi',
       );
   }
}
