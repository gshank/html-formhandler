use Test::More tests => 8;

use HTML::FormHandler::Field::Text;


{
   package Test::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::Simple';

   has '+name' => ( default => 'options_form' );
   has_field 'test_field' => (
               type => 'Text',
               label => 'TEST',
               id    => 'f99',
            );
   has_field 'fruit' => ( type => 'Select' );
   has_field 'vegetables' => ( type => 'Multiple' );

   sub options_fruit {
       return (
           1   => 'apples',
           2   => 'oranges',
           3   => 'kiwi',
       );
   }

   sub options_vegetables {
       return (
           1   => 'lettuce',
           2   => 'broccoli',
           3   => 'carrots',
           4   => 'peas',
       );
   }
}


my $form = Test::Form->new;
ok( $form, 'create form');

is_deeply( [$form->field('vegetables')->options], 
   [ {'label' => 'lettuce',
      'value' => 1 },
     {'label' => 'broccoli',
      'value' => 2 },
     {'label' => 'carrots',
      'value' => 3 },
     {'label' => 'peas',
      'value' => 4 } ],
   'get options for vegetables' );
is_deeply( [$form->field('fruit')->options],
    [ {'label' => 'apples',
       'value' => 1 },
      {'label' => 'oranges',
       'value' => 2 },
      {'label' => 'kiwi',
       'value' => 3 } ],
    'get options for fruit' );

my $params = {
   fruit => 2,
   vegetables => [2,4],
};

$form->validate( $params );
ok( $form->validated, 'form validated' );
is( $form->field('fruit')->value, 2, 'fruit value is correct');
is_deeply( $form->field('vegetables')->value, [2,4], 'vegetables value is correct');

is_deeply( $form->fif, { fruit => 2, vegetables => [2, 4] }, 'fif is correct');
is_deeply( $form->values, { fruit => 2, vegetables => [2, 4] }, 'values are correct');

