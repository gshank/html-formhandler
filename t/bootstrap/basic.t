use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Basic::Theme;
    use Moose::Role;

    # make a wrapper around the form
    sub build_do_form_wrapper {1}
    # set the class for the form wrapper
    sub build_form_wrapper_class { ['span9'] }
    # set the class for the form element
    sub build_form_element_class { ['well'] }
    # set various rendering tags
    sub build_form_tags {
        {   wrapper_tag => 'div',
            before => qq{<div class="row"><div class="span3"><p>With v2.0, we have
               lighter and smarter defaults for form styles. No extra markup, just
               form controls.</p></div>\n},
            after => '</div>',
        }
    }

    # the settings in 'build_update_subfields' are merged with the field
    # definitions before they are constructed
    sub build_update_subfields {{
       # all fields have a label but no wrapper
       all => { do_wrapper => 0, do_label => 1 },
       # set the element class, a placeholder in element_attr
       foo => { element_class => ['span3'],
           element_attr => { placeholder => 'Type something…' },
           tags => { after_element =>
              qq{\n<span class="help-inline">Associated help text!</span>} } },
       bar => { option_label => 'Check me out',
          label_class => ['checkbox'], do_label => 0 },
       submit_btn => { element_class => ['btn'] },
    }}
}

{
    package MyApp::Form::Basic;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'MyApp::Form::Basic::Theme';
    with 'HTML::FormHandler::Widget::Theme::BootstrapFormMessages';

    has '+name' => ( default => 'basic_form' );
    has_field 'foo' => ( type => 'Text' );
    has_field 'bar' => ( type => 'Checkbox' );
    has_field 'submit_btn' => ( type => 'Submit', value => 'Submit', widget => 'ButtonTag' );
}

my $form = MyApp::Form::Basic->new;
ok( $form, 'form built' );
$form->process({});
my $rendered = $form->render;

my $expected = '<div class="row">
    <div class="span3">
      <p>With v2.0, we have lighter and smarter defaults for form styles. No extra markup, just form controls.</p>
    </div>
    <div class="span9">
      <form class="well" method="post" id="basic_form">
        <label for="foo">Foo</label>
        <input type="text" class="span3" placeholder="Type something…" name="foo" id="foo" value="">
        <span class="help-inline">Associated help text!</span>
        <label class="checkbox" for="bar">
          <input type="checkbox" name="bar" id="bar" value="1"> Check me out </label>
        <button type="submit" class="btn" name="submit_btn" id="submit_btn">Submit</button>
      </form>
    </div>
  </div> <!-- /row -->';

is_html($rendered, $expected, 'rendered correctly');

# check foo
$rendered = $form->field('foo')->render;
$expected =
'<label for="foo">Foo</label>
<input type="text" class="span3" placeholder="Type something…" name="foo" id="foo" value="">
<span class="help-inline">Associated help text!</span>';
is_html($rendered, $expected, 'foo field is correct' );

# check bar
$rendered = $form->field('bar')->render;
$expected =
'<label class="checkbox" for="bar">
 <input type="checkbox" name="bar" id="bar" value="1"> Check me out </label>';
is_html($rendered, $expected, 'bar field is correct' );

$form->process( params => {}, info_message => 'Fill in the form!' );
$rendered = $form->render_form_messages;
$expected =
'<div class="alert alert-info"><span>Fill in the form!</span>';
is_html($rendered, $expected, 'info message rendered ok' );

done_testing;
