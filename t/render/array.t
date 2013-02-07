use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Repeatable::Array;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'my_array' => ( type => 'Repeatable', num_when_empty => 2,
        do_wrapper => 1, do_label => 1 );
    has_field 'my_array.contains' => ( type => 'Text', do_wrapper => 0, do_label => 0 );
    has_field 'my_array2' => ( type => 'Repeatable', num_when_empty => 2,
        do_wrapper => 1, do_label => 1 );
    has_field 'my_array2.contains' => ( type => 'Text', widget_wrapper => 'None' );
    has_field 'my_rep' => ( type => 'Repeatable', 'num_when_empty' => 2 );
    #  we want a label but not a div wrapper
    has_field 'my_rep.foo' => ( do_wrapper => 0 );
    has_field 'bar';

}

my $form = Test::Repeatable::Array->new;

my $expected =
'<fieldset id="my_array"><legend>My array</legend>
  <input type="text" name="my_array.0" id="my_array.0" value="" />
  <input type="text" name="my_array.1" id="my_array.1" value="" />
</fieldset>';
my $rendered = $form->field('my_array')->render;
is_html($rendered, $expected, 'repeatable array field renders correctly');

$expected =
'<fieldset id="my_array2"><legend>My array2</legend>
  <input type="text" name="my_array2.0" id="my_array2.0" value="" />
  <input type="text" name="my_array2.1" id="my_array2.1" value="" />
</fieldset>';
$rendered = $form->field('my_array2')->render;
is_html($rendered, $expected, 'repeatable array field renders correctly');

$rendered = $form->field('my_rep')->render;
$expected =
'<div class="hfh-repinst" id="my_rep.0">
  <label for="my_rep.0.foo">Foo</label>
  <input type="text" name="my_rep.0.foo" id="my_rep.0.foo" value="" />
</div>
<div class="hfh-repinst" id="my_rep.1">
  <label for="my_rep.1.foo">Foo</label>
  <input type="text" name="my_rep.1.foo" id="my_rep.1.foo" value="" />
</div>';
is_html($rendered, $expected, 'simple repeatable renders correctly');

$form->process( params => {} );
my $rendered_form = $form->render;

$rendered = $form->field('my_array')->render;
$expected =
'<fieldset id="my_array"><legend>My array</legend>
  <input type="text" name="my_array.0" id="my_array.0" value="" />
  <input type="text" name="my_array.1" id="my_array.1" value="" />
</fieldset>';
is_html($rendered, $expected, 'repeatable array renders after process' );

$rendered = $form->field('my_rep')->render;
$expected =
'<div class="hfh-repinst" id="my_rep.0">
  <label for="my_rep.0.foo">Foo</label>
  <input type="text" name="my_rep.0.foo" id="my_rep.0.foo" value="" />
</div>
<div class="hfh-repinst" id="my_rep.1">
  <label for="my_rep.1.foo">Foo</label>
  <input type="text" name="my_rep.1.foo" id="my_rep.1.foo" value="" />
</div>';
is_html($rendered, $expected, 'simple repeatable renders correctly after process');

$form->process( params => { foo => 'xxx', bar => 'yyy',
   'my_array.0' => 'one', 'my_array.1' => 'two',
   'my_rep.0.foo' => 'fee', 'my_rep.1.foo' => 'fie' } );
$rendered = $form->render;
$rendered = $form->field('my_array')->render;
$expected =
'<fieldset id="my_array"><legend>My array</legend>
  <input type="text" name="my_array.0" id="my_array.0" value="one" />
  <input type="text" name="my_array.1" id="my_array.1" value="two" />
</fieldset>';
is_html($rendered, $expected, 'array renders ok after processing with params' );

$rendered = $form->field('my_rep')->render;
$expected =
'<div class="hfh-repinst" id="my_rep.0">
  <label for="my_rep.0.foo">Foo</label>
  <input type="text" name="my_rep.0.foo" id="my_rep.0.foo" value="fee" />
</div>
<div class="hfh-repinst" id="my_rep.1">
  <label for="my_rep.1.foo">Foo</label>
  <input type="text" name="my_rep.1.foo" id="my_rep.1.foo" value="fie" />
</div>';
is_html($rendered, $expected, 'repeatable renders ok after processing with params' );

done_testing;
