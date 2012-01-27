use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Repeatable::Array;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'my_array' => ( type => 'Repeatable', num_when_empty => 2 );
    has_field 'my_array.contains' => ( type => 'Text' );
    has_field 'my_rep' => ( type => 'Repeatable', 'num_when_empty' => 2 );
    has_field 'my_rep.foo';
    has_field 'bar';

}

my $form = Test::Repeatable::Array->new;
my $expected =
'<div><label for="my_array.0">0</label><input type="text" name="my_array.0" id="my_array.0" value="" />
</div>
<div><label for="my_array.1">1</label><input type="text" name="my_array.1" id="my_array.1" value="" />
</div>';
my $rendered = $form->field('my_array')->render;
is_html($rendered, $expected, 'repeatable array field renders correctly');

$rendered = $form->field('my_rep')->render;
$expected = '<div><label for="my_rep.0.foo">Foo</label><input type="text" name="my_rep.0.foo" id="my_rep.0.foo" value="" />
</div>
<div><label for="my_rep.1.foo">Foo</label><input type="text" name="my_rep.1.foo" id="my_rep.1.foo" value="" />
</div>';
is_html($rendered, $expected, 'simple repeatable renders correctly');

$form->process( params => {} );
my $rendered_form = $form->render;

$rendered = $form->field('my_array')->render;
$expected =
'<div><label for="my_array.0">0</label><input type="text" name="my_array.0" id="my_array.0" value="" />
</div>
<div><label for="my_array.1">1</label><input type="text" name="my_array.1" id="my_array.1" value="" />
</div>';
is_html($rendered, $expected, 'repeatable array renders after process' );

$rendered = $form->field('my_rep')->render;
$expected = '<div><label for="my_rep.0.foo">Foo</label><input type="text" name="my_rep.0.foo" id="my_rep.0.foo" value="" />
</div>
<div><label for="my_rep.1.foo">Foo</label><input type="text" name="my_rep.1.foo" id="my_rep.1.foo" value="" />
</div>';
is_html($rendered, $expected, 'simple repeatable renders correctly after process');

$form->process( params => { foo => 'xxx', bar => 'yyy',
   'my_array.0' => '', 'my_array.1' => '',
   'my_rep.0.foo' => '', 'my_rep.1.foo' => '' } );
$rendered = $form->render;
$rendered = $form->field('my_array')->render;
$expected = '<div><label for="my_array.0">0</label><input type="text" name="my_array.0" id="my_array.0" value="" />
</div>
<div><label for="my_array.1">1</label><input type="text" name="my_array.1" id="my_array.1" value="" />
</div>';
is_html($rendered, $expected, 'array renders ok after processing with params' );
$rendered = $form->field('my_rep')->render;
$expected = '<div><label for="my_rep.0.foo">Foo</label><input type="text" name="my_rep.0.foo" id="my_rep.0.foo" value="" />
</div>
<div><label for="my_rep.1.foo">Foo</label><input type="text" name="my_rep.1.foo" id="my_rep.1.foo" value="" />
</div>';
is_html($rendered, $expected, 'repeatable renders ok after processing with params' );

done_testing;
