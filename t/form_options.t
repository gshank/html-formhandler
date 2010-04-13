use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Field::Text;


{
   package Test::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'options_form' );
   has_field 'test_field' => (
               type => 'Text',
               label => 'TEST',
               id    => 'f99',
            );
   has_field 'fruit' => ( type => 'Select' );
   has_field 'vegetables' => ( type => 'Multiple', input_without_param => [], not_nullable => 1 );
   has_field 'empty' => ( type => 'Multiple' );
   has_field 'build_attr' => ( type => 'Select' );

   sub init_value_fruit { 2 }

   # the following sometimes happens with db options
   sub options_empty { ([]) }

   has 'options_fruit' => ( is => 'rw', traits => ['Array'],
       default => sub { [1 => 'apples', 2 => 'oranges',
           3 => 'kiwi'] } );

   sub options_vegetables {
       return (
           1   => 'lettuce',
           2   => 'broccoli',
           3   => 'carrots',
           4   => 'peas',
       );
   }

   has 'options_build_attr' => ( is => 'ro', traits => ['Array'], lazy_build => 1 );

   sub _build_options_build_attr {
       return [
           1 => 'testing',
           2 => 'moose',
           3 => 'attr builder',
       ];
   }
}


my $form = Test::Form->new;
ok( $form, 'create form');

my $veg_options =   [ {'label' => 'lettuce',
      'value' => 1 },
     {'label' => 'broccoli',
      'value' => 2 },
     {'label' => 'carrots',
      'value' => 3 },
     {'label' => 'peas',
      'value' => 4 } ];
my $field_options = $form->field('vegetables')->options;
is_deeply( $field_options, $veg_options,
   'get options for vegetables' );

my $fruit_options = [ {'label' => 'apples',
       'value' => 1 },
      {'label' => 'oranges',
       'value' => 2 },
      {'label' => 'kiwi',
       'value' => 3 } ];
$field_options = $form->field('fruit')->options;
is_deeply( $field_options, $fruit_options,
    'get options for fruit' );

my $build_attr_options = [ {'label' => 'testing',
       'value' => 1 },
      {'label' => 'moose',
       'value' => 2 },
      {'label' => 'attr builder',
       'value' => 3 } ];
$field_options = $form->field('build_attr')->options;
is_deeply( $field_options, $build_attr_options,
    'get options for fruit' );

my $params = {
   fruit => 2,
   vegetables => [2,4],
   empty => '',
};

is( $form->field('fruit')->value, 2, 'initial value ok');

$form->process( params => {},
    init_object => { vegetables => undef, fruit => undef, build_attr => undef } );
$field_options = $form->field('vegetables')->options;
is_deeply( $field_options, $veg_options,
   'get options for vegetables after process' );
$field_options = $form->field('fruit')->options;
is_deeply( $field_options, $fruit_options,
    'get options for fruit after process' );
$field_options = $form->field('build_attr')->options;
is_deeply( $field_options, $build_attr_options,
    'get options for fruit after process' );


$form->process( $params );
ok( $form->validated, 'form validated' );
is( $form->field('fruit')->value, 2, 'fruit value is correct');
is_deeply( $form->field('vegetables')->value, [2,4], 'vegetables value is correct');

is_deeply( $form->fif, { fruit => 2, vegetables => [2, 4], test_field => '', empty => '', build_attr => '' }, 
    'fif is correct');
is_deeply( $form->values, { fruit => 2, vegetables => [2, 4], empty => undef }, 
    'values are correct');

$params = {
    fruit => 2, 
};
$form->process($params);
is_deeply( $form->field('vegetables')->value, [], 'value for vegetables correct' );


done_testing;
