use Test::More tests => 10;

use HTML::FormHandler::Field::Text;


{
   package Test::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::Simple';

   has '+name' => ( default => 'renderform' );
   has_field 'test_field' => (
               type => 'Text',
               label => 'TEST',
               id    => 'f99',
            );
   has_field 'fruit' => ( type => 'Select' );
   has_field 'vegetables' => ( type => 'Multiple' );
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

   has '+dependency' => ( default => sub { [ ['start_date.month',
         'start_date.day', 'start_date.year'] ] } );
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
   fruit => 2,
   vegetables => [2,4],
   active => 'now',
   comments => 'Four score and seven years ago...',
   hidden => '1234',
   selected => '1',
   'start_date.month' => '7',
   'start_date.day' => '14', 
   'start_date.year' => '2006', 
};

$form->validate( $params );


my $output1 = $form->render_field( $form->field('test_field') );
is( $output1, 
   '
<label class="label" for="test_field">TEST:</label><input type="text" name="test_field" id="f99" value="something">',
   'output from text field');

my $output2 = $form->render_field( $form->field('fruit') );
is( $output2, 
   '<label class="label" for="fruit">Fruit</label><select name="fruit""><option value="1" >apples</option><option value="2" selected="selected">oranges</option><option value="3" >kiwi</option></select>',
   'output from select field');

my $output3 = $form->render_field( $form->field('vegetables') );
is( $output3, 
   '<label class="label" for="vegetables">Vegetables</label><select name="vegetables" multiple="multiple" size="5""><option value="2"  selected="selected">broccoli</option><option value="4"  selected="selected">peas</option><option value="1" >lettuce</option><option value="3" >carrots</option></select>',
   'output from select multiple field');

my $output4 = $form->render_field( $form->field('active') );
is( $output4, 
   '<label class="label" for="active">Active</label><input type="checkbox" name="active" value="1"/>', 
   'output from checkbox field');

my $output5 = $form->render_field( $form->field('comments') );
is( $output5, 
   '
<label class="label" for="comments">Comments: </label><textarea name="comments" id="renderformcomments" rows="5" cols="10">Four score and seven years ago...</textarea>',
   'output from textarea' );

my $output6 = $form->render_field( $form->field('hidden') );
is( $output6,
   '
<label class="label" for="hidden">Hidden:</label><input type="hidden" name="hidden" id="renderformhidden" value="1234">', 
   'output from hidden field' );

my $output7 = $form->render_field( $form->field('selected') );
is( $output7, 
   '<label class="label" for="selected">Selected</label><input type="checkbox" name="selected" value="1" checked="checked"/>',
   'output from boolean' );

my $output8 = $form->render_field( $form->field('start_date') );
is( $output8, 
   '<fieldset class="start_date">
<label class="label" for="month">Month:</label><input type="text" name="month" id="renderformmonth" value="7">
<label class="label" for="day">Day:</label><input type="text" name="day" id="renderformday" value="14">
<label class="label" for="year">Year:</label><input type="text" name="year" id="renderformyear" value="2006"></fieldset>',
   'output from DateTime' );

my $output = $form->render;
ok( $output, 'get rendered output from form');
