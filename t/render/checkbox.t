use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
   {
       package Test::Form;
       use HTML::FormHandler::Moose;
       extends 'HTML::FormHandler';

       has_field 'option1' => ( type => 'Checkbox', tags => { checkbox_single_label => 1 } );
       has_field 'option2' => ( type => 'Checkbox', tags => { checkbox_single_label => 1, label_left => 1 } );
       has_field 'option3' => ( type => 'Checkbox', option_label => 'Try this one' );
       has_field 'option4' => ( type => 'Checkbox', tags => { checkbox_unwrapped => 1 } );
   }
   my $form = Test::Form->new;
   $form->process;

   # standard - label wraps input, label to right
   my $expected =
'<div>
  <label for="option1"><input id="option1" name="option1" type="checkbox" value="1" />Option1</label>
</div>';
   my $rendered = $form->field('option1')->render;
   is_html( $rendered, $expected, 'standard Checkbox render ok' );

   # label wraps input, label to left
   $expected =
'<div>
  <label for="option2">Option2<input id="option2" name="option2" type="checkbox" value="1" /></label>
</div>';
   $rendered = $form->field('option2')->render;
   is_html( $rendered, $expected, 'Checkbox with label to left' );

   # checkbox with additional label (like Bootstrap)
   $expected =
'<div>
  <label>Option3</label>
    <label class="checkbox" for="option3"><input id="option3" name="option3" type="checkbox" value="1" />Try this one</label>
</div>';
   $rendered = $form->field('option3')->render;
   is_html( $rendered, $expected, 'Checkbox with two labels' );

   # label unwrapped
   $expected =
'<div>
  <label for="option4">Option4</label>
  <input id="option4" name="option4" type="checkbox" value="1" />
</div>';
   $rendered = $form->field('option4')->render;
   is_html( $rendered, $expected, 'Checkbox with unwrapped label');


}

done_testing;
