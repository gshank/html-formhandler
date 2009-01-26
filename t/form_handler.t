use strict;
use warnings;
use Test::More;
my $tests = 9;
plan tests => $tests;

use_ok( 'HTML::FormHandler' );

{
   package My::Form;
   use Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'testform_' );

   sub field_list {
       return {
           required    => {
               reqname     => 'Text',
               fruit       => 'Select',
           },
           optional    => {
               optname     => 'Text',
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

ok( !$form->validate, 'Empty data' );

$form->clear_state;

my $good = {
    reqname => 'hello',
    optname => 'not req',
    fruit   => 2,
};

ok( $form->validate( $good ), 'Good data' );

my $bad_1 = {
    optname => 'not req',
    fruit   => 4,
};

$form->clear_state;
ok( !$form->validate( $bad_1 ), 'bad 1' );

ok( $form->field('fruit')->has_errors, 'fruit has error' );

ok( $form->field('reqname')->has_errors, 'reqname has error' );

ok( !$form->field('optname')->has_errors, 'optname has no error' );

is( $form->field('fruit')->id, "testform_fruit", 'field has id' ); 

is( $form->field('fruit')->label, 'Fruit', 'field label');

$form->clear_state;


