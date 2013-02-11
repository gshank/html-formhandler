use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

# an example of how to setup a form for adding repeatable elements.
{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::RepeatableJs';

    # Note: if using RepeatableJs, repeatable elements must be
    # wrapped in a 'controls' div (like the Bootstrap wrapper)
    #       set 'setup_for_js' flag
    #       do_wrapper is turned on by 'setup_for_js' flag
    has_field 'foo' => (
        type => 'Repeatable',
        setup_for_js => 1,
        do_wrapper => 1,
        tags => { controls_div => 1 },
    );

    # The 'remove' doesn't have to be a display field. It could be other html associated
    # with the repeatable element wrapper or label.
    has_field 'foo.remove' => (
        type => 'RmElement',
        value => 'Remove',
    );
    has_field 'foo.one';
    has_field 'foo.two';

    # 'AddElement' field is right after repeatable field
    # It also doesn't need to be a display field. Any way to get the correct HTML in is ok.
    # It requires the name of the repeatable (as accessed from AddElement parent)
    # The 'value' is the button text. See the AddElement field for requirements.
    has_field 'add_element' => (
        type => 'AddElement',
        repeatable => 'foo',
        value => 'Add another foo',
    );
    has_field 'bar';

}

my $form = MyApp::Form::Test->new;
ok( $form );

ok( $form->has_for_js, 'for_js data is built');

my $js = $form->render_repeatable_js;
ok( $js, 'got some javascript' );

my $expected = '
<div>
  <div class="add_element btn" data-rep-id="foo" id="add_element">Add another foo</div>
</div>';
my $rendered = $form->field('add_element')->render;
is_html( $rendered, $expected, 'add_element rendered ok' );

$expected = '
<fieldset id="foo">
  <div class="controls">
    <div class="hfh-repinst" id="foo.0">
      <div>
          <div class="rm_element btn" data-rep-elem-id="foo.0" id="foo.0.remove">Remove</div>
      </div>
      <div>
        <label for="foo.0.one">One</label>
        <input id="foo.0.one" name="foo.0.one" type="text" value="" />
      </div>
      <div>
        <label for="foo.0.two">Two</label>
        <input id="foo.0.two" name="foo.0.two" type="text" value="" />
      </div>
    </div>
  </div>
</fieldset>';
$rendered = $form->field('foo')->render;
is_html( $rendered, $expected, 'repeatable field renders ok' );


done_testing;
