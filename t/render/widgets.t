use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

use lib 't/lib';

use HTML::FormHandler::Field::Text;

{

    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_do_form_wrapper {1}
    sub build_update_subfields {{
        by_flag => { compound => { do_wrapper => 1, do_label => 1 },
            repeatable => { do_wrapper => 1, do_label => 1 },
        },
    }}
    sub build_form_wrapper_class { 'form_wrapper' }
    has '+name' => ( default => 'testform' );
    has_field 'test_field' => (
        size  => 20,
        label => 'TEST',
        id    => 'f99',
        element_class => 'test123',
    );
    has_field 'number';
    has_field hobbies => (
        type => 'Repeatable',
        num_when_empty => 1,
    );

    has_field 'hobbies.contains' => (
        type => 'Text',
        tabindex => 2,
    );
    has_field 'active'     => ( type => 'Checkbox' );
    has_field 'comments'   => ( type => 'TextArea', cols => 40, rows => 3 );
    has_field 'hidden'     => ( type => 'Hidden' );
    has_field 'selected'   => ( type => 'Boolean' );
    has_field 'start_date' => ( type => 'DateTime', tags => { wrapper_tag => 'fieldset' } );
    has_field 'start_date.month' => (
        type        => 'Integer',
        range_start => 1,
        range_end   => 12
    );
    has_field 'start_date.day' => (
        type        => 'Integer',
        range_start => 1,
        range_end   => 31
    );
    has_field 'start_date.year' => (
        type        => 'Integer',
        range_start => 2000,
        range_end   => 2020
    );

    has_field 'two_errors' => (
        apply => [
            { check => [], message => 'First constraint error' },
            { check => [], message => 'Second constraint error' }
        ]
    );

    has_field 'submit' => ( type => 'Submit', value => '>>> Update' );
    has_field 'reset' => ( type => 'Reset', value => '<<< Reset' );

    has '+dependency' => (
        default => sub {
            [ [ 'start_date.month', 'start_date.day', 'start_date.year' ] ];
        }
    );
    has_field 'no_render' => ( widget => 'NoRender' );
    has_field 'plain' => ( widget_wrapper => 'None' );
    has_field 'boxed' => ( widget_wrapper => 'Fieldset', wrapper_attr => { class => 'boxed' } );
    has_field 'element_wrapper_field' => ( element_wrapper_class => 'large' );

    sub html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        $attr->{class} = 'label' if $type eq 'label';
        return $attr;
    }
}

my $form = Test::Form->new;
ok( $form, 'create form' );

my $expected =
'<fieldset id="hobbies"><legend class="label">Hobbies</legend>
  <div>
    <label class="label" for="hobbies.0">0</label>
    <input type="text" name="hobbies.0" id="hobbies.0" value="" tabindex="2" />
  </div>
</fieldset>';
is_html( $form->field('hobbies')->render, $expected, 'output from repeatable with num_when_empty == 1'
);

my $params = {
    test_field         => 'something',
    number             => 0,
    active             => 'now',
    comments           => 'Four score and seven years ago...</textarea>',
    hidden             => '1234',
    selected           => '1',
    'start_date.month' => '7',
    'start_date.day'   => '14',
    'start_date.year'  => '2006',
    two_errors         => 'aaa',
    plain              => 'No divs!!',
    hobbies            => [ 'eating', 'sleeping', 'not chasing mice' ],
    boxed              => 'Testing single fieldset',
};

$form->process($params);

is_html(
    $form->field('number')->render,
'<div>
  <label class="label" for="number">Number</label>
  <input type="text" name="number" id="number" value="0" />
</div>',
    "value '0' is rendered"
);

my $rendered = $form->field('test_field')->render;
is_html( $rendered,
'<div>
  <label class="label" for="f99">TEST</label>
  <input type="text" name="test_field" id="f99" size="20" value="something" class="test123" />
</div>',
    'output from text field'
);

$rendered = $form->field('test_field')->render_element;
is_html( $rendered,
    '<input type="text" name="test_field" id="f99" size="20" value="something" class="test123" />',
    'output from render_element is correct'
);

$expected =
'<div>
  <label class="label" for="active">Active</label>
    <label class="checkbox" for="active">
      <input id="active" name="active" type="checkbox" value="1" />
    </label>
</div>';
is_html( $form->field('active')->render, $expected, 'output from checkbox field');

$rendered = $form->field('comments')->render;
is_html( $rendered,
'<div>
  <label class="label" for="comments">Comments</label>
  <textarea name="comments" id="comments" rows="3" cols="40">Four score and seven years ago...&lt;/textarea&gt;</textarea>
</div>',
    'output from textarea'
);

$rendered = $form->field('hidden')->render;
is_html( $rendered,
'<div>
  <input type="hidden" name="hidden" id="hidden" value="1234" />
</div>',
    'output from hidden field'
);

$rendered = $form->field('selected')->render;
is_html( $rendered,
'<div>
  <label class="label" for="selected">Selected</label>
    <label class="checkbox" for="selected">
      <input checked="checked" id="selected" name="selected" type="checkbox" value="1" />
    </label>
</div>',
    'output from boolean'
);

$rendered = $form->field('start_date')->render;
is_html( $rendered,
'<fieldset id="start_date"><legend class="label">Start date</legend>
  <div>
    <label class="label" for="start_date.month">Month</label>
    <input type="text" name="start_date.month" id="start_date.month" size="8" value="7" />
  </div>
  <div>
    <label class="label" for="start_date.day">Day</label>
    <input type="text" name="start_date.day" id="start_date.day" size="8" value="14" />
  </div>
  <div>
    <label class="label" for="start_date.year">Year</label>
    <input type="text" name="start_date.year" id="start_date.year" size="8" value="2006" />
  </div>
</fieldset>',
    'output from DateTime'
);

$rendered = $form->field('submit')->render;
is_html( $rendered,
'<div>
  <input type="submit" name="submit" id="submit" value="&gt;&gt;&gt; Update" />
</div>', 'output from Submit' );

$rendered = $form->field('reset')->render;
is_html( $rendered,
'<div>
  <input type="reset" name="reset" id="reset" value="&lt;&lt;&lt; Reset" />
</div>', 'output from Reset'
);

$rendered = $form->render_start;
is_html( $rendered,
'<form id="testform" method="post"><fieldset class="form_wrapper">',
'Form start OK'
);

$rendered = $form->field('hobbies')->render;
is_html( $rendered, '
<fieldset id="hobbies"><legend class="label">Hobbies</legend>
  <div>
    <label class="label" for="hobbies.0">0</label>
    <input type="text" name="hobbies.0" id="hobbies.0" value="eating" tabindex="2" />
  </div>
  <div>
    <label class="label" for="hobbies.1">1</label>
    <input type="text" name="hobbies.1" id="hobbies.1" value="sleeping" tabindex="2" />
  </div>
  <div>
    <label class="label" for="hobbies.2">2</label>
    <input type="text" name="hobbies.2" id="hobbies.2" value="not chasing mice" tabindex="2" />
  </div>
</fieldset>', 'output from repeatable after processing result with 3 items' );

is( $form->field('no_render')->render, '', 'no_render' );

is_html( $form->field('plain')->render, '<input type="text" name="plain" id="plain" value="No divs!!" />', 'renders without wrapper');

is_html( $form->field('boxed')->render,
'<fieldset class="boxed"><legend>Boxed</legend>
  <input type="text" name="boxed" id="boxed" value="Testing single fieldset" />
</fieldset>', 'fieldset wrapper renders' );

is_html( $form->field('element_wrapper_field')->render,
'<div>
  <label class="label" for="element_wrapper_field">Element wrapper field</label>
  <div class="large">
    <input id="element_wrapper_field" name="element_wrapper_field" type="text" value="" />
  </div>
</div>',
   'element wrapper renders ok' );

# table widget
$form = Test::Form->new( widget_form => 'Table', widget_wrapper => 'Table' );
like( $form->render, qr/<table/, 'rendered form contains table' );
like( $form->field('number')->render, qr/<td>/, 'field has table wrapper');
$form->process($params);
my $outputT = $form->render;
ok( $outputT, 'output from table rendering' );

done_testing;
