use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
   {
       package Test::Form;
       use HTML::FormHandler::Moose;
       extends 'HTML::FormHandler';

       has_field 'option1' => ( type => 'Checkbox', do_label => 0 );
       has_field 'option2' => ( type => 'Checkbox', do_label => 0, tags => { label_left => 1 } );
       has_field 'option3' => ( type => 'Checkbox', option_label => 'Try this one' );
       has_field 'option4' => ( type => 'Checkbox', tags => { no_wrapped_label => 1 } );
       has_field 'option5' => ( type => 'Checkbox', widget_wrapper => 'None' );
       has_field 'option6' => ( type => 'Checkbox', do_label => 0,
          do_wrapper => 0, label => 'Simple Checkbox' );
   }
   my $form = Test::Form->new;
   $form->process;

   # single_label: label wraps input, label to right
   my $expected =
'<div>
  <label class="checkbox" for="option1"><input id="option1" name="option1" type="checkbox" value="1" /> Option1 </label>
</div>';
   my $rendered = $form->field('option1')->render;
   is_html( $rendered, $expected, 'standard Checkbox render ok' );

   # single_label: label wraps input, label to left
   $expected =
'<div>
  <label class="checkbox" for="option2"> Option2 <input id="option2" name="option2" type="checkbox" value="1" /></label>
</div>';
   $rendered = $form->field('option2')->render;
   is_html( $rendered, $expected, 'Checkbox with label to left' );

   # standard: checkbox with additional label (like Bootstrap)
   $expected =
'<div>
  <label for="option3">Option3</label>
    <label class="checkbox" for="option3">
      <input id="option3" name="option3" type="checkbox" value="1" />
      Try this one
    </label>
</div>';
   $rendered = $form->field('option3')->render;
   is_html( $rendered, $expected, 'Checkbox with two labels' );

   # no wrapped label
   $expected =
'<div>
  <label for="option4">Option4</label>
  <input id="option4" name="option4" type="checkbox" value="1" />
</div>';
   $rendered = $form->field('option4')->render;
   is_html( $rendered, $expected, 'Checkbox with no wrapped label');

   # wrapper = 'None', input element only
   $expected =
   '<input id="option5" name="option5" type="checkbox" value="1" />';
   $rendered = $form->field('option5')->render;
    is_html( $rendered, $expected, 'Checkbox with no wrapper and no label' );

    # no wrapper
    $expected =
'<label class="checkbox" for="option6">
  <input id="option6" name="option6" type="checkbox" value="1" />
  Simple Checkbox
</label>';
    $rendered = $form->field('option6')->render;
    is_html( $rendered, $expected, 'checkbox with no wrapper, wrapped label' );

}

done_testing;
