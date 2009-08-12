use strict;
use warnings;
use Test::More;

use_ok('HTML::FormHandler');

{

   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name'         => ( default  => 'testform_' );
   has_field 'optname' => ( temp     => 'First' );
   has_field 'reqname' => ( required => 1 );
   has_field 'somename';
   has_field 'my_selected' => ( type => 'Checkbox' );
   has_field 'must_select' => ( type => 'Checkbox', required => 1 );

   sub field_list
   {
      return [
         fruit   => 'Select',
         optname => { temp => 'Second' }
      ];
   }

   sub options_fruit
   {
      return (
         1 => 'apples',
         2 => 'oranges',
         3 => 'kiwi',
      );
   }
}

my $form = My::Form->new;

is( $form->field('optname')->temp, 'Second', 'got second optname field' );

ok( !$form->process, 'Empty data' );

my $good = {
   reqname     => 'hello',
   optname     => 'not req',
   fruit       => 2,
   must_select => 1,
};

ok( $form->process($good), 'Good data' );
is( $form->field('somename')->value, undef, 'no value for somename' );
ok( !$form->field('somename')->has_value, 'predicate no value' );
$good->{somename} = 'testing';
$form->process($good);
is( $form->field('somename')->value,    'testing', 'use input for extra data' );
is( $form->field('my_selected')->value, 0,         'correct value for unselected checkbox' );

ok( !$form->process( {} ), 'form doesn\'t validate with empty params' );
is( $form->num_errors, 0, 'form doesn\'t have errors with empty params' );

my $bad_1 = {
   reqname => '',
   optname => 'not req',
   fruit   => 4,
};

ok( !$form->process($bad_1),                 'bad 1' );
ok( $form->field('fruit')->has_errors,       'fruit has error' );
ok( $form->field('reqname')->has_errors,     'reqname has error' );
ok( $form->field('must_select')->has_errors, 'must_select has error' );
ok( !$form->field('optname')->has_errors,    'optname has no error' );
is( $form->field('fruit')->id,    "fruit", 'field has id' );
is( $form->field('fruit')->label, 'Fruit',          'field label' );

ok( !$form->process( {} ), 'no leftover params' );
is( $form->num_errors, 0, 'no leftover errors' );
ok( !$form->field('reqname')->has_errors, 'no leftover error in field' );
ok( !$form->field('optname')->fif,        'no lefover fif values' );

my $init_object = {
   reqname => 'Starting Perl',
   optname => 'Over Again'
};
$form = My::Form->new( init_object => $init_object );
is( $form->field('optname')->value, 'Over Again', 'get right value from form' );
$form->process( params => {} );
ok( !$form->validated, 'form validated' );
is_deeply( $form->values, $init_object, 'get right values from form' );
$init_object->{my_selected} = 0;    # checkboxes must be forced to 0
my %fif = %$init_object;
$fif{somename}    = '';
$fif{fruit}       = '';
$fif{must_select} = 0;
is_deeply( $form->fif, \%fif, 'get right fif with init_object' );
# make sure that checkbox is 0 in values
$init_object->{must_select} = 1;
$fif{must_select} = 1;
ok( $form->process($init_object), 'form validates with params' );
is_deeply( $form->values, $init_object, 'get right values from form' );
is_deeply( $form->fif, \%fif, 'get right fif with init_object' );

$form->clear;
ok( !$form->has_value, 'Form value cleared' );
ok( !$form->has_input, 'Form input cleared' );

# check that form is cleared if fif is done before process
$form->fif;
$form->process($init_object);
is_deeply( $form->fif, \%fif, 'get right fif when process preceded by fif');

$form = HTML::FormHandler->new( field_list => [ foo => { type => 'Text', required => 1 } ] );

if ( !$form->process( params => { bar => 1, } ) )
{
   # On some versions, the above process() returned false, but
   # error_fields did not return anything.
   my @fields = $form->error_fields;
   if ( is( scalar @fields, 1, "there is an error field" ) )
   {
      my @errors = $fields[0]->errors;
      is( scalar @errors, 1, "there is an error" );

      is( $errors[0], $fields[0]->label . " field is required", "error messages match" );
   }
   else
   {
      fail("there is an error");
      fail("error messages match");
   }
}

done_testing;
