use strict;
use warnings;
use Test::More;
my $tests = 15;
plan tests => $tests;

use_ok( 'HTML::FormHandler' );

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'testform_' );

   has_field 'optname' => ( temp => 'First' );

   has_field 'reqname' => ( required => 1 );

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

ok( !$form->validate( {} ), 'form doesn\'t validate with empty params' );
is( $form->num_errors, 0, 'form doesn\'t have errors with empty params' );

my $bad_1 = {
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

