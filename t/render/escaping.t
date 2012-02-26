use strict;
use warnings;
use Test::More;

use HTML::FormHandler::Test;
use HTML::FormHandler::Field::Text;


{
   package Test::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::Simple';

   sub build_update_subfields {{
       all => { do_wrapper => 1, tags => { label_after => ': ' }},
       by_flag => { compound => { do_wrapper => 1 }},
   }}
   sub build_do_form_wrapper {1}
   sub build_form_wrapper_class { 'form_wrapper' }
   has '+name' => ( default => 'testform' );
   has_field 'test_field' => (
               size => 20,
               label => '"TEST"',
               id    => 'f99',
            );
   has_field 'number';
   has_field 'fruit' => ( type => 'Select' );
   has_field 'vegetables' => ( type => 'Multiple' );
   has_field 'opt_in' => ( type => 'Select', widget => 'RadioGroup',
      options => [{ value => 0, label => '<No>'}, { value => 1, label => '<Yes>'} ] );
   has_field 'active' => ( type => 'Checkbox' );
   has_field 'comments' => ( type => 'TextArea' );
   has_field 'hidden' => ( type => 'Hidden' );
   has_field 'selected' => ( type => 'Boolean' );
   has_field 'two_errors' => (
       apply => [
          { check   => [ ], message => 'First constraint error' },
          { check   => [ ], message => 'Second constraint error' }
       ]
   );

   has_field 'submit' => ( type => 'Submit', value => 'Update' );

   has '+dependency' => ( default => sub { [ ['start_date.month',
         'start_date.day', 'start_date.year'] ] } );
   has_field 'no_render' => ( widget => 'NoRender' );
   sub options_fruit {
       return (
           1   => '"apples"',
           2   => '<oranges>',
           3   => '&kiwi&',
       );
   }

   sub options_vegetables {
       return (
           1   => '<lettuce>',
           2   => 'broccoli',
           3   => 'carrots',
           4   => 'peas',
       );
   }

}


my $form = Test::Form->new;
ok( $form, 'create form');

my $params = {
   test_field => 'something<br>',
   number => 0,
   fruit => 2,
   vegetables => [2,4],
   active => 'now',
   comments => 'Four score and seven years ago...</textarea>',
   hidden => '<1234>',
   selected => '1',
   two_errors => 'aaa',
   opt_in => 0,
};

$form->process( $params );

is_html( $form->render_field( $form->field('number') ),
    '
<div><label for="number">Number: </label><input type="text" name="number" id="number" value="0" />
</div>',
    "value '0' is rendered"
);

my $rendered = $form->render_field( $form->field('test_field') );

my $expected =   '
<div><label for="f99">&quot;TEST&quot;: </label><input type="text" name="test_field" id="f99" size="20" value="something&lt;br&gt;" />
</div>';
is_html( $rendered, $expected, 'output from text field');
is_html( $form->field('test_field')->render, $rendered, 'text field with widgets' );


$rendered = $form->render_field( $form->field('fruit') );
$expected =  '
<div><label for="fruit">Fruit: </label><select name="fruit" id="fruit"><option value="1" id="fruit.0">&quot;apples&quot;</option><option value="2" id="fruit.1" selected="selected">&lt;oranges&gt;</option><option value="3" id="fruit.2">&amp;kiwi&amp;</option></select>
</div>';
is_html( $rendered, $expected, 'output from select field');

$rendered = $form->render_field( $form->field('vegetables') );
is_html( $rendered,
   '
<div><label for="vegetables">Vegetables: </label><select name="vegetables" id="vegetables" multiple="multiple" size="5"><option value="1" id="vegetables.0">&lt;lettuce&gt;</option><option value="2" id="vegetables.1" selected="selected">broccoli</option><option value="3" id="vegetables.2">carrots</option><option value="4" id="vegetables.3" selected="selected">peas</option></select>
</div>',
'output from select multiple field');

$rendered = $form->render_field( $form->field('active') );
is_html( $rendered,
   '
<div><label for="active">Active: </label><input type="checkbox" name="active" id="active" value="1" />
</div>',
   'output from checkbox field');

$rendered = $form->render_field( $form->field('comments') );
is_html( $rendered,
   '
<div><label for="comments">Comments: </label><textarea name="comments" id="comments" rows="5" cols="10">Four score and seven years ago...&lt;/textarea&gt;</textarea>
</div>',
   'output from textarea' );

$rendered = $form->render_field( $form->field('hidden') );
is_html( $rendered,
   '<div><input type="hidden" name="hidden" id="hidden" value="&lt;1234&gt;" /></div>',
   'output from hidden field' );

$rendered = $form->render_field( $form->field('selected') );
is_html( $rendered,
   '
<div><label for="selected">Selected: </label><input type="checkbox" name="selected" id="selected" value="1" checked="checked" />
</div>',
   'output from boolean' );

$rendered = $form->render_field( $form->field('submit') );
is_html( $rendered, q{
<div><input type="submit" name="submit" id="submit" value="Update" />
</div>}, 'output from Submit');

$rendered = $form->render_field( $form->field('opt_in') );
is_html( $rendered, q{
<div><label for="opt_in">Opt in: </label> <br /><label for="opt_in.0"><input type="radio" value="0" name="opt_in" id="opt_in.0" checked="checked" />&lt;No&gt;</label><br /><label for="opt_in.1"><input type="radio" value="1" name="opt_in" id="opt_in.1" />&lt;Yes&gt;</label><br />
</div>}, 'output from radio group' );

$rendered = $form->render_start;
is_html( $rendered,
'<fieldset class="form_wrapper"><form id="testform" method="post">',
'Form start OK' );

my $output = $form->render;
ok( $output, 'get rendered output from form');

is_html( $form->render_field( $form->field('no_render')), '', 'no_render' );

done_testing;
