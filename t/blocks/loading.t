use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

use lib ('t/lib');

use_ok('MyApp::Component::Section');

my $obj = MyApp::Component::Section->new;
ok( $obj, 'created section' );
my $rendered = $obj->render;
my $expected =
'<div class="intro">
  <h3>Please enter the relevant details</h3>
</div>';
is_html( $rendered, $expected, 'section rendered standalone' );

{
    package MyApp::Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'testform' );
    has_block 'section1' => ( type => '+MyApp::Component::Section' );
    has_field 'foo';
    has_field 'bar';
    sub build_render_list { ['section1', 'foo', 'bar'] }

}

my $form = MyApp::Test::Form->new;
ok( $form, 'form built' );

$rendered = $form->render;

$expected =
'<form id="testform" method="post">
  <div class="form_messages"></div>
  <div class="intro">
    <h3>Please enter the relevant details</h3>
  </div>
  <div>
    <label for="foo">Foo</label>
    <input type="text" id="foo" name="foo" value="" />
  </div>
  <div>
    <label for="bar">Bar</label>
    <input type="text" id="bar" name="bar" value="" />
  </div>
</form>';
is_html( $rendered, $expected, 'rendered ok' );

done_testing;
