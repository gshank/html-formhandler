use strict;
use warnings;
use Test::More;
use Test::Differences;
#use IO::All;

use_ok('HTML::FormHandler::Result');

{
   package Test::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+widget_form' => ( default => 'Simple' );
   has '+name' => ( default => 'testform' );
   has_field 'test_field' => (
               size => 20,
               label => 'TEST',
               id    => 'f99',
            );
   has_field 'number';
   has_field 'fruit' => ( type => 'Select' );
   has_field 'vegetables' => ( type => 'Multiple' );
   has_field 'opt_in' => ( type => 'Select', widget => 'radio_group',
      options => [{ value => 0, label => 'No'}, { value => 1, label => 'Yes'} ] );
   has_field 'active' => ( type => 'Checkbox' );
   has_field 'comments' => ( type => 'TextArea' );
   has_field 'hidden' => ( type => 'Hidden' );
   has_field 'selected' => ( type => 'Boolean' );
   has_field 'start_date' => ( type => 'DateTime' );
   has_field 'start_date.month' => ( type => 'Integer', range_start => 1,
       range_end => 12 );
   has_field 'start_date.day' => ( type => 'Integer', range_start => 1,
       range_end => 31 );
   has_field 'start_date.year' => ( type => 'Integer', range_start => 2000,
       range_end => 2020 );

   has_field 'two_errors' => (
       apply => [
          { check   => [ ], message => 'First constraint error' },
          { check   => [ ], message => 'Second constraint error' }
       ]
   );

   has_field 'submit' => ( type => 'Submit', value => 'Update' );

   has '+dependency' => ( default => sub { [ ['start_date.month',
         'start_date.day', 'start_date.year'] ] } );
   has_field 'no_render' => ( widget => 'no_render' );
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


my $params1 = {
   test_field => 'something',
   number => 0,
   fruit => 2,
   vegetables => [2,4],
   active => 'now',
   comments => 'Four score and seven years ago...',
   hidden => '1234',
   selected => '1',
   'start_date.month' => '7',
   'start_date.day' => '14',
   'start_date.year' => '2006',
   two_errors => 'aaa',
   opt_in => 0,
};

$form->process( $params1 );

my $outputf = $form->render;
ok( $outputf, 'get rendered output from form');

my $result1 = $form->result;
ok( $result1, 'get result' );

my $outputr = $result1->render;
ok( $outputr, 'get render from result');

eq_or_diff( $outputf, $outputr, 'no diff form and result');

my $params2 = {
   test_field => 'anything',
   number => 2,
   fruit => 3,
   vegetables => [2,4],
   active => 'now',
   comments => 'Four centuries and seven years ago...',
   hidden => '5678',
   selected => '0',
   'start_date.month' => '9',
   'start_date.day' => '14',
   'start_date.year' => '2008',
   two_errors => 'aaa',
   opt_in => 1,
};


my $result2 = $form->run($params2);
my $outputr2 = $result1->render;
eq_or_diff( $outputr, $outputr2, 'no diff second execution');

#$outputr > io('first_result.txt');
#$outputr2 > io('second_result.txt');
#my $diff = `diff first_result.txt second_result.txt`;
#diag( $diff );

$form->process($params1);

eq_or_diff( $result1->field('test_field')->render, $form->field('test_field')->render, 'no diff test_field' );
eq_or_diff( $result1->field('number')->render, $form->field('number')->render, 'no diff number' );
eq_or_diff( $result1->field('fruit')->render, $form->field('fruit')->render, 'no diff fruit' );
eq_or_diff( $result1->field('vegetables')->render, $form->field('vegetables')->render, 'no diff vegetables' );
eq_or_diff( $result1->field('active')->render, $form->field('active')->render, 'no diff active' );
eq_or_diff( $result1->field('comments')->render, $form->field('comments')->render, 'no diff comments' );
eq_or_diff( $result1->field('hidden')->render, $form->field('hidden')->render, 'no diff hidden' );
eq_or_diff( $result1->field('selected')->render, $form->field('selected')->render, 'no diff selected' );
eq_or_diff( $result1->field('start_date.month')->render, $form->field('start_date.month')->render, 'no diff start_date.month' );
eq_or_diff( $result1->field('start_date.day')->render, $form->field('start_date.day')->render, 'no diff start_date.day' );
eq_or_diff( $result1->field('start_date.year')->render, $form->field('start_date.year')->render, 'no diff start_date.year' );
eq_or_diff( $result1->field('two_errors')->render, $form->field('two_errors')->render, 'no diff two_errors' );
eq_or_diff( $result1->field('opt_in')->render, $form->field('opt_in')->render, 'no diff opt_in' );


done_testing;
