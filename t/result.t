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
   has_field 'fruit' => ( type => 'Select' );
   has_field 'optname' => ( temp => 'Second' );
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
ok( $form->result, 'result exists' );
ok( $form->field('optname'), 'result field exists' );

my $good = {
   reqname     => 'hello',
   optname     => 'not req',
   fruit       => 2,
   must_select => 1,
};

$form->process($good);
ok( $form->validated, 'Good data' );
my $result = $form->result;
ok( $result, 'got result object' );
ok( $result->validated, 'result validated');
ok( $result->has_input, 'result still has input');
my $num_errors = $form->num_errors;

$result = $form->run($good);
ok( !$form->has_result, 'has result after been cleared');
ok( !$form->validated, 'form has been cleared' );

# field still points to existing result
ok( !$form->field('reqname')->input, 'no input for field');
ok( !$form->field('reqname')->value, 'no value for field');
ok( $result->validated, 'result still has result' );
is( $result->num_errors, $num_errors, 'number of errors is correct');
is( $result->field('somename')->value, undef, 'no value for somename' );
ok( !$result->field('somename')->has_value, 'predicate no value' );

$good->{my_selected} = 0;
$good->{somename} = '';
is_deeply( $result->fif, $good, 'fif is correct' );
delete $good->{my_selected};

$form->process({});
ok( !$form->field('reqname')->input, 'no input for field');

$good->{somename} = 'testing';
$result = $form->run($good);
is( $result->field('somename')->value,    'testing', 'use input for extra data' );
is( $result->field('my_selected')->value, 0,         'correct value for unselected checkbox' );

$result = $form->run( {} );

ok( !$result->validated, 'form doesn\'t validate with empty params' );
is( $result->num_errors, 0, 'form doesn\'t have errors with empty params' );


my $bad_1 = {
   reqname => '',
   optname => 'not req',
   fruit   => 4,
};

$result = $form->run($bad_1);
ok( !$result->validated,                 'bad 1' );
ok( $result->field('fruit')->has_errors,       'fruit has error' );
ok( $result->field('reqname')->has_errors,     'reqname has error' );
ok( $result->field('must_select')->has_errors, 'must_select has error' );
ok( !$result->field('optname')->has_errors,    'optname has no error' );

$result = $form->run;
ok( !$result->validated, 'no leftover params' );
is( $result->num_errors, 0, 'no leftover errors' );
ok( !$result->field('reqname')->has_errors, 'no leftover error in field' );
ok( !$result->field('optname')->fif,        'no lefover fif values' );

my $init_object = {
   reqname => 'Starting Perl',
   optname => 'Over Again'
};
$form = My::Form->new( init_object => $init_object );
is( $form->field('optname')->value, 'Over Again', 'get right value from form' );
$result = $form->run( params => {} );
ok( !$result->validated, 'form did not validate' );
my $values = {
   'fruit' => undef,
   'must_select' => 0,
   'my_selected' => 0,
   'optname' => 'Over Again',
   'reqname' => 'Starting Perl',
   'somename' => undef
};
is_deeply( $result->value, $values, 'get right values from form' );

$init_object->{my_selected} = 0;
$init_object->{must_select} = 1;
$result = $form->run($init_object);
ok( $result->validated, 'form validates with params' );
is_deeply( $result->value, $init_object, 'get right values from result' );

ok( !$form->has_value, 'Form value cleared' );
ok( !$form->has_input, 'Form input cleared' );

$form = HTML::FormHandler->new( field_list => [ foo => { type => 'Text', required => 1 } ] );

# 'image' input produces { foo => bar, 'foo.x' => 42, 'foo.y' => 23 }
$form = HTML::FormHandler->new( name => 'baz', html_prefix => 1, field_list => [ 'foo' ] );
eval{ $result =  $form->run( params => {  'baz.foo' => 'bar', 'baz.foo.x' => 42, 'baz.foo.y' => 23  } ) };
ok( !$@, 'image field processed' ) or diag $@;
is_deeply( $result->field( 'foo' )->value, { '' => 'bar', x => 42, y => 23 }, 'image input value correct' );

done_testing;
