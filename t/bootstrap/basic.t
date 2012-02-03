use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

# this tests that instead of constructing a 14 line form easily in
# a template, you can also construct it with 15 (additional) lines of Perl
{
    package MyApp::Form::Basic::Theme;
    use Moose::Role;

    # set class for form tag (form_element_attr) and form wrapper (form_wrapper_attr)
    sub build_form_wrapper_attr { { class => 'span9' } }
    sub build_form_element_attr { { class => 'well' } }
    sub build_widget_tags {
        # wrap the form with outside div (form_wrapper = 1, form_wrapper_tag = div)
        # wrap the fields (to get label) but with no wrapping div ( wrapper_tag => 0 )
        { form_wrapper => 1, form_wrapper_tag => 'div', wrapper_tag => 0,
            form_before => qq{<div class="row"><div class="span3"><p>With v2.0, we have lighter and smarter defaults for form styles. No extra markup, just form controls.</p></div>\n},
            form_after => '</div>',
        }
    }

    # individual field settings, including classes for form elements (form_element_attr),
    # field wrappers (wrapper_attr), field labels (label_attr)
    # widget_wrapper, labels strings,
    # extra bits of rendering (after_element)
    sub build_update_fields {{
       foo => { element_class => ['span3'], element_attr => { placeholder => 'Type something…' },
           widget_tags => { after_element => '<span class="help-inline">Associated help text!</span>' } },
       bar => { label => 'Check me out', label_class => ['checkbox'] },
       submit_btn => { element_class => ['btn'] },
    }}
}

{
    package MyApp::Form::Basic;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'MyApp::Form::Basic::Theme';

    has '+name' => ( default => 'basic_form' );
    has_field 'foo' => ( type => 'Text' );
    has_field 'bar' => ( type => 'Checkbox' );
    has_field 'submit_btn' => ( type => 'Submit', value => 'Submit', widget => 'ButtonTag' );
}

my $expected = '<div class="row">
    <div class="span3">
      <p>With v2.0, we have lighter and smarter defaults for form styles. No extra markup, just form controls.</p>
    </div>
    <div class="span9">
      <form class="well" method="post" id="basic_form">
        <label for="foo">Foo</label>
            <input type="text" class="span3" placeholder="Type something…" name="foo" id="foo" value=""><span class="help-inline">Associated help text!</span>
        <label class="checkbox" for="bar">
          <input type="checkbox" name="bar" id="bar" value="1">Check me out</label>
        <button type="submit" class="btn" name="submit_btn" id="submit_btn">Submit</button>
      </form>
    </div>
  </div> <!-- /row -->';

my $form = MyApp::Form::Basic->new;
ok( $form, 'form built' );
$form->process({});
my $rendered = $form->render;
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
 <input type="checkbox" name="bar" id="bar" value="1">Check me out</label>';
is_html($rendered, $expected, 'bar field is correct' );

done_testing;
