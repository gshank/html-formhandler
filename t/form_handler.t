use strict;
use warnings;
use Test::More;
my $tests = 24;
plan tests => $tests;

use_ok( 'HTML::FormHandler' );

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'testform_' );
   has_field 'optname' => ( temp => 'First' );
   has_field 'reqname' => ( required => 1 );
   has_field 'somename';
   sub field_list {
       return {
           fields    => {
               fruit       => 'Select',
               optname     => {
                  temp => 'Second'
               }
           },
       };
   }
   sub options_fruit {
       return (
           1   => 'apples',
           2   => 'oranges',
           3   => 'kiwi',
       );
   }
}

my $form = My::Form->new;

is( $form->field('optname')->temp, 'Second', 'got second optname field' );

ok( !$form->validate, 'Empty data' );

my $good = {
    reqname => 'hello',
    optname => 'not req',
    fruit   => 2,
};

ok( $form->validate( $good ), 'Good data' );
is( $form->field('somename')->value, undef, 'no value for somename');
ok( !$form->field('somename')->has_value, 'predicate no value');
$form->field('somename')->input('testing');
$form->validate;
is( $form->field('somename')->value, 'testing', 'use input for extra data');

ok( !$form->validate( {} ), 'form doesn\'t validate with empty params' );
is( $form->num_errors, 0, 'form doesn\'t have errors with empty params' );

my $bad_1 = {
    reqname => '',
    optname => 'not req',
    fruit   => 4,
};


ok( !$form->validate( $bad_1 ), 'bad 1' );
ok( $form->field('fruit')->has_errors, 'fruit has error' );
ok( $form->field('reqname')->has_errors, 'reqname has error' );
ok( !$form->field('optname')->has_errors, 'optname has no error' );
is( $form->field('fruit')->id, "testform_fruit", 'field has id' ); 
is( $form->field('fruit')->label, 'Fruit', 'field label');


ok( !$form->validate( {} ), 'no leftover params' );
is( $form->num_errors, 0, 'no leftover errors' );
ok( !$form->field('reqname')->has_errors, 'no leftover error in field');
ok( !$form->field('optname')->fif, 'no lefover fif values');

my $init_object = { reqname => 'Starting Perl',
                    optname => 'Over Again' };
$form = My::Form->new( init_object => $init_object );
is( $form->field('optname')->value, 'Over Again', 'get right value from form');
$form->validate({});
ok( !$form->validated, 'form validated' );
is_deeply( $form->fif, $init_object, 'get right fif with init_object');
is_deeply( $form->values, $init_object, 'get right values from form'); 

ok( $form->validate( $init_object ), 'form validates with params' );


