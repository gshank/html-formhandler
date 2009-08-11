use Test::More tests => 16;

use HTML::FormHandler::Field::Text;


{
   package Test::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::Simple';

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
   has_field 'end_date' => ( type => 'Date' );

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

my $params = {
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

$form->process( $params );

is( $form->render_field( $form->field('number') ),
    '
<div><label class="label" for="number">Number: </label><input type="text" name="number" id="number" value="0" /></div>
',
    "value '0' is rendered"
);

my $output1 = $form->render_field( $form->field('test_field') );
is( $output1,
   '
<div><label class="label" for="f99">TEST: </label><input type="text" name="test_field" id="f99" size="20" value="something" /></div>
',
   'output from text field');

my $output2 = $form->render_field( $form->field('fruit') );
is( $output2,
   '
<div><label class="label" for="fruit">Fruit: </label><select name="fruit" id="fruit"><option value="1" id="fruit.0" >apples</option><option value="2" id="fruit.1" selected="selected">oranges</option><option value="3" id="fruit.2" >kiwi</option></select></div>
',
   'output from select field');

my $output3 = $form->render_field( $form->field('vegetables') );
is( $output3,
   '
<div><label class="label" for="vegetables">Vegetables: </label><select name="vegetables" id="vegetables" multiple="multiple" size="5"><option value="2" id="vegetables.0" selected="selected">broccoli</option><option value="4" id="vegetables.1" selected="selected">peas</option><option value="1" id="vegetables.2" >lettuce</option><option value="3" id="vegetables.3" >carrots</option></select></div>
',
   'output from select multiple field');

my $output4 = $form->render_field( $form->field('active') );
is( $output4,
   '
<div><label class="label" for="active">Active: </label><input type="checkbox" name="active" id="active" value="1" /></div>
',
   'output from checkbox field');

my $output5 = $form->render_field( $form->field('comments') );
is( $output5,
   '
<div><label class="label" for="comments">Comments: </label><textarea name="comments" id="comments" rows="5" cols="10">Four score and seven years ago...</textarea></div>
',
   'output from textarea' );

my $output6 = $form->render_field( $form->field('hidden') );
is( $output6,
   '
<div><input type="hidden" name="hidden" id="hidden" value="1234" /></div>
',
   'output from hidden field' );

my $output7 = $form->render_field( $form->field('selected') );
is( $output7,
   '
<div><label class="label" for="selected">Selected: </label><input type="checkbox" name="selected" id="selected" value="1" checked="checked" /></div>
',
   'output from boolean' );

my $output8 = $form->render_field( $form->field('start_date') );
is( $output8,
   '
<div><fieldset class="start_date"><legend>Start_date</legend>
<div><label class="label" for="start_date.month">Month: </label><input type="text" name="start_date.month" id="start_date.month" size="8" value="7" /></div>

<div><label class="label" for="start_date.day">Day: </label><input type="text" name="start_date.day" id="start_date.day" size="8" value="14" /></div>

<div><label class="label" for="start_date.year">Year: </label><input type="text" name="start_date.year" id="start_date.year" size="8" value="2006" /></div>
</fieldset></div>
',
   'output from DateTime' );

my $output9 = $form->render_field( $form->field('submit') );
is( $output9, '
<div><input type="submit" name="submit" id="submit" value="Update" /></div>
', 'output from Submit');

my $output10 = $form->render_field( $form->field('opt_in') );
is( $output10, '
<div><label class="label" for="opt_in">Opt_in: </label> <br /><input type="radio" value="0" name="opt_in" id="opt_in.0" />No<br /><input type="radio" value="1" name="opt_in" id="opt_in.1" />Yes<br /></div>
', 'output from radio group' );

my $output11 = $form->render_start;
is( $output11,'<form id="testform" method="post">
<fieldset class="main_fieldset">', 'Form start OK' );

my $output12 = $form->render_field( $form->field('end_date') );
ok( $output12, 'date field rendered' );

my $output = $form->render;
ok( $output, 'get rendered output from form');

is( $form->render_field( $form->field('no_render')), '', 'no_render' );
