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
   has_field 'vegetables' => ( type => 'Multiple' );
   has_field 'empty' => ( type => 'Multiple', no_option_validation => 1 );
   has_field 'build_attr' => ( type => 'Select' );

   sub default_fruit { 2 }

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
my $field_options = $form->field('vegetables')->options_ref;
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
$field_options = $form->field('build_attr')->options_ref;
is_deeply( $field_options, $build_attr_options,
    'get options for fruit' );

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

my $params = {
   fruit => 2,
   vegetables => [2,4],
   empty => 'test',
};

$form->process( $params );
ok( $form->validated, 'form validated' );
is( $form->field('fruit')->value, 2, 'fruit value is correct');
is_deeply( $form->field('vegetables')->value, [2,4], 'vegetables value is correct');

is_deeply( $form->fif, { fruit => 2, vegetables => [2, 4], empty => ['test'], test_field => '', build_attr => '' },
    'fif is correct');
is_deeply( $form->values, { fruit => 2, vegetables => [2, 4], empty => ['test'], build_attr => undef },
    'values are correct');
is( $form->field('vegetables')->as_label, 'broccoli, peas', 'multiple as_label works');
is( $form->field('vegetables')->as_label([3,4]), 'carrots, peas', 'pass in multiple as_label works');

$params = {
    fruit => 2,
    vegetables => 4,
};
$form->process($params);
is_deeply( $form->field('vegetables')->value, [4], 'value for vegetables correct' );
is_deeply( $form->field('vegetables')->fif, [4], 'fif for vegetables correct' );

{
    package Test::Form2;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'my_list' => ( type => 'Select' );

    # this adds a 'selected' hash key to an option as an alternative
    # to setting the default for the field.
    sub options_my_list {
        return [
            {
                value => 1,
                label => 'One',
                selected => 1,
            },
            {
                value => 2,
                label => 'Two',
            },
            {
                value => 3,
                label  => 'Three',
            }
        ];
    }

}

$form = Test::Form2->new;
ok( $form, 'form built' );

my $rendered_field = $form->field('my_list')->render;
like( $rendered_field, qr/<option value="1" id="my_list\.0" selected="selected">/, 'element is selected' );
# the 'value' of the field should reflect the selected values
is_deeply( $form->value, { my_list => 1 },  'value ok' );
ok( $form->field('my_list')->fif, 'fif value');
$form->process( { my_list => 2 } );
is_deeply( $form->fif, { my_list => 2 }, 'fif is correct' );
$rendered_field = $form->field('my_list')->render;
like( $rendered_field, qr/<option value="2" id="my_list\.1" selected="selected">/, 'element is selected' );

# following test is for 'has_many' select field flag
{
    package Test::HasMany;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( default => 'my_foo' );
    has_field 'hm_bar' => ( type => 'Multiple',
        has_many => 'my_id', default => [3] );

    sub options_hm_bar { [1, 2, 3, 4] }
}
$form = Test::HasMany->new;
ok( $form, 'has many form built' );
$form->process( params => {} );
my $fif_expected = { foo => 'my_foo', hm_bar => [3] };
is_deeply( $form->fif, $fif_expected, 'got expected fif' );
$form->process( params => { foo => 'my_foo', hm_bar => [4] } );
my $val_expected = { foo => 'my_foo', hm_bar => [ { my_id => 4 } ] };
is_deeply( $form->value, $val_expected, 'got expected value' );
$fif_expected = { foo => 'my_foo', hm_bar => [4] };
is_deeply( $form->fif, $fif_expected, 'got expected fif' );
$form->process( params => { foo => 'my_foo', hm_bar => [1,2] } );
$fif_expected = { foo => 'my_foo', hm_bar => [1,2] };
is_deeply( $form->fif, $fif_expected, 'got expected fif again' );
$val_expected = { foo => 'my_foo', hm_bar => [ { my_id => 1 }, { my_id => 2 } ] };
is_deeply( $form->value, $val_expected, 'got expected value agina' );

{
    package Test::Multiple::InitObject;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( default => 'my_foo' );
    has_field 'bar' => ( type => 'Multiple' );

   sub options_bar {
       return (
           1   => 'one',
           2   => 'two',
           3   => 'three',
           4   => 'four',
       );
   }


}

$form = Test::Multiple::InitObject->new;
my $init_object = { foo => 'new_foo', bar => [3,4] };
$form->process(init_object => $init_object, params => {} );
my $rendered = $form->render;
like($rendered, qr/<option value="4" id="bar.1" selected="selected">four<\/option>/, 'rendered option');
my $value = $form->value;
is_deeply( $value, $init_object, 'correct value');

done_testing;
