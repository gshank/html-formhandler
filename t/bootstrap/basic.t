use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Basic::Theme;
    use Moose::Role;

    sub render_before_form {
        qq{<div class="row"><div class="span3"><p>With v2.0, we have lighter and smarter defaults for form styles. No extra markup, just form controls.</p></div>\n}
    }
    sub render_after_form { '</div>' }
    sub build_wrapper_attr { { class => 'span9' } }
    sub build_html_attr { { class => 'well' } }
    sub build_widget_tags {
        { form_wrapper => 1, form_wrapper_tag => 'div', wrapper_tag => 0 }
    }
    sub build_field_rendering {{
       foo => { html_attr => { class => 'span3', placeholder => 'Type something…' },
           widget_tags => { after_element => '<span class="help-inline">Associated help text!</span>' } },
       bar => { label => 'Check me out', label_attr => { class => 'checkbox' } },
       submit_btn => { html_attr => { class => 'btn' } },
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
$rendered = $form->field('foo')->render;
$expected = '<label for="foo">Foo</label>
<input type="text" class="span3" placeholder="Type something…" name="foo" id="foo" value=""><span class="help-inline">Associated help text!</span>';
is_html($rendered, $expected, 'foo field is correct' );

done_testing;
