use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Field::Record;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    sub build_update_subfields {{
        all => {
            wrapper_class => 'wrap',
            tags => { 'before_element' => '<p>A comment</p>' }
        },
        'sam' => { label_class => 'sam_label' },
    }}

    has_field 'flot';
    has_field 'jet';
    has_field 'sam';

}

{
    package MyApp::Form::Complex;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test_form' );
    has '+field_name_space' => ( default => sub{ ['MyApp::Form::Field'] } );

    has_field 'foo';
    has_field 'bar' => ( type => 'Record' );

}

my $form = MyApp::Form::Complex->new;
ok( $form, 'form built' );
$form->process;
my $rendered = $form->render;
my $expected =
'<form id="test_form" method="post">
  <div class="form_messages"></div>
  <div>
    <label for="foo">Foo</label>
    <input id="foo" name="foo" type="text" value="" />
  </div>
  <div class="wrap">
    <label for="bar.flot">Flot</label>
    <p>A comment</p>
    <input id="bar.flot" name="bar.flot" type="text" value="" />
  </div>
  <div class="wrap">
    <label for="bar.jet">Jet</label>
    <p>A comment</p>
    <input id="bar.jet" name="bar.jet" type="text" value="" />
  </div>
  <div class="wrap">
    <label class="sam_label" for="bar.sam">Sam</label>
    <p>A comment</p>
    <input id="bar.sam" name="bar.sam" type="text" value="" />
  </div>
</form>';

is_html( $rendered, $expected, 'rendered as expected' );

done_testing;
