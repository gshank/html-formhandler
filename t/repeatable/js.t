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

    # Note: if using RepeatableJs, repeatable must use Bootstrap wrapper
    #   but other wrappers can be 'Simple'
    #       set 'setup_for_js' flag
    #       do_wrapper is turned on by 'setup_for_js' flag
    has_field 'foo' => (
        type => 'Repeatable',
        setup_for_js => 1,
        widget_wrapper => 'Bootstrap',
        do_wrapper => 1,
    );

    # The 'remove' doesn't have to be a display field. It could be other html associated
    # with the repeatable element wrapper or label.
    has_field 'foo.remove' => (
        type => 'Display', render_method => \&render_remove );
    sub render_remove {
        my $self = shift; # self is field
        my $id = $self->parent->id;
        return qq{<span class="btn rm_element" data-rep-elem-id="$id">Remove</span>};
    }
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
<div class="control-group" id="foo">
  <div class="controls">
    <div class="hfh-repinst" id="foo.0">
      <span class="btn rm_element" data-rep-elem-id="foo.0">Remove</span>
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
</div>';
$rendered = $form->field('foo')->render;
is_html( $rendered, $expected, 'repeatable field renders ok' );


done_testing;
