use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::MyBlocks;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar';
    has_field 'flim';
    has_field 'flam';
    has_field 'fee';
    has_field 'fie';
    has_field 'fo';
    has_field 'fum';

    has_block 'abc' => ( render_list => ['foo', 'fo'] );
    has_block 'def' => ( render_list => ['bar', 'fum'], label => "My DEF Block",
        label_class => ['block', 'label'] );
    has_block 'ghi' => ( render_list => ['flim', 'flam'], wrapper => 0 );
}

my $form = MyApp::Form::MyBlocks->new;

my $rendered .= $form->block('ghi')->render;
$rendered .= $form->field('fie')->render;
$rendered .= $form->block('abc')->render;
$rendered .= $form->field('fee')->render;
$rendered .= $form->block('def')->render;

my $expected =
'<div>
  <label for="flim">Flim</label>
  <input id="flim" name="flim" type="text" value="" />
</div>
<div>
  <label for="flam">Flam</label>
  <input id="flam" name="flam" type="text" value="" />
</div>
<div>
  <label for="fie">Fie</label>
  <input id="fie" name="fie" type="text" value="" />
</div>
<div>
  <div>
    <label for="foo">Foo</label>
    <input id="foo" name="foo" type="text" value="" />
  </div>
  <div>
    <label for="fo">Fo</label>
    <input id="fo" name="fo" type="text" value="" />
  </div>
</div>
<div>
  <label for="fee">Fee</label>
  <input id="fee" name="fee" type="text" value="" />
</div>
<div>
  <span class="block label">My DEF Block</span>
  <div>
    <label for="bar">Bar</label>
    <input id="bar" name="bar" type="text" value="" />
  </div>
  <div>
    <label for="fum">Fum</label>
    <input id="fum" name="fum" type="text" value="" />
  </div>
</div>';


is_html($rendered, $expected, 'rendered correctly' );


done_testing;
