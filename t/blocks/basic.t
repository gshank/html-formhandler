use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

use_ok('HTML::FormHandler::Blocks');
use_ok('HTML::FormHandler::Widget::Block');
use lib ('t/lib');

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test_form' );
    has '+widget_name_space' => ( default => sub {'Widget'} );
    sub build_render_list {
        ['header', 'foo', 'my_fieldset']
    }
    has_field 'foo';
    has_field 'bar';
    has_block 'my_fieldset' => ( tag => 'fieldset',
        render_list => ['bar'], label => 'My Special Bar' );
    has_block 'header' => ( type => 'Test' );

}
my $form = Test::Form->new;
ok( $form, 'form built' );
my $block = $form->block('my_fieldset');
is( ref $block, 'HTML::FormHandler::Widget::Block', 'got a block' );
is_deeply( $form->render_list, ['header', 'foo', 'my_fieldset'], 'got a render list' );
is_deeply( $block->render_list, ['bar'], 'got a render list from the block' );
$form->process;
my $rendered = $form->render;
my $expected =
'<form id="test_form" method="post">
  <div class="form_messages"></div>
  <h2>You got to the Block! Congratulations.</h2>
  <div>
    <label for="foo">Foo</label>
    <input type="text" name="foo" id="foo" value="" />
 </div>
 <fieldset><legend>My Special Bar</legend>
   <div>
     <label for="bar">Bar</label>
     <input type="text" name="bar" id="bar" value="" />
   </div>
 </fieldset>
</form>';
is_html( $rendered, $expected, 'block rendered ok' );

done_testing;
