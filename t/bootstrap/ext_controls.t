use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::ExtControls;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Widget::Theme::Bootstrap';

    sub build_form_tags {{
        after_start => "<fieldset>\n<legend>Extending form controls</legend>",
    }}
    sub build_process_list { ['form_sizes', 'prependedInput', 'appendedInput', 'inlineCheckboxes',
        'checkboxList'] }
    has_block 'form_sizes' => ( type => 'Bootstrap', render_list => ['text1', 'text2', 'text3'],
        label => 'Form sizes',
        after_controls => '<p class="help-block">Use the same <code>.span*</code> classes from the grid system for input sizes.</p>',
    );
    # these three fields are in the 'form_sizes' block
    has_field 'text1' => ( widget_wrapper => 'None', element_class => ['span2'],
        element_attr => { placeholder => '.span2' } );
    has_field 'text2' => ( widget_wrapper => 'None', element_class => ['span3'],
        element_attr => { placeholder => '.span3' } );
    has_field 'text3' => ( widget_wrapper => 'None', element_class => ['span4'],
        element_attr => { placeholder => '.span4' } );

    has_field 'prependedInput' => ( label => 'Prepended text', size => 16, element_class => ['span2'],
        tags => { input_prepend =>  '@', after_element => '<p class="help-block">Here\'s some help text</p>' }
    );
    has_field 'appendedInput' => ( label => 'Appended text', size => 16, element_class => ['span2'],
        tags => { input_append =>  '.00', after_element => '<p class="help-block">Here\'s more help text</p>' }
    );

    has_field 'inlineCheckboxes' => ( type => 'Multiple', widget => 'CheckboxGroup',
        label => 'Inline checkboxes',
        tags => { inline => 1 }, options => [ { value => 'option1', label => '1' },
            { value => 'option2', label => '2' }, { value => 'option3', label => '3' } ],
    );

    has_block 'checkboxList' => ( type => 'Bootstrap', label => 'Checkboxes',
        render_list => ['optionsCheckboxList1', 'optionsCheckboxList2', 'optionsCheckboxList3' ],
        after_controls => '<p class="help-text"><strong>Note:</strong> Labels surround all the options for much larger click areas and a more usable form.</p>'
    );
    has_field 'optionsCheckboxList1' => ( type => 'Checkbox', do_wrapper => 0, do_label => 0,
        checkbox_value => 'option1',
        option_label => 'Option one is this and that—be sure to include why it’s great',
    );
    has_field 'optionsCheckboxList2' => ( type => 'Checkbox', do_wrapper => 0, do_label => 0,
        checkbox_value => 'option2',
        option_label => 'Option two can also be checked and included in form results',
    );
    has_field 'optionsCheckboxList3' => ( type => 'Checkbox', do_wrapper => 0, do_label => 0,
        checkbox_value => 'option3',
        option_label => 'Option three can—yes, you guessed it—also be checked and included in form results',
    );

    has_field 'optionsRadios' => ( type => 'Multiple', widget => 'RadioGroup',
        label => 'Radio buttons',
        options => [
            { value => 'option1', label => 'Option one is this and that—be sure to include why it’s great' },
            { value => 'option2', label => 'Option two can is something else and selecting it will deselect option one' },
        ]
    );
}

my $form = MyApp::Form::ExtControls->new;
ok( $form, 'form built' );
$form->process;
my $expected =
'<div class="control-group">
  <label class="control-label">Form sizes</label>
  <div class="controls">
    <input id="text1" name="text1" class="span2" type="text" placeholder=".span2" value="" />
    <input id="text2" name="text2" class="span3" type="text" placeholder=".span3" value="" />
    <input id="text3" name="text3" class="span4" type="text" placeholder=".span4" value="" />
    <p class="help-block">Use the same <code>.span*</code> classes from the grid system for input sizes.</p>
  </div>
</div>';
my $rendered = $form->block('form_sizes')->render;
is_html( $rendered, $expected, 'form_sizes block rendered ok' );

$expected =
'<div class="control-group">
  <label class="control-label" for="prependedInput">Prepended text</label>
  <div class="controls">
    <div class="input-prepend">
      <span class="add-on">@</span>
      <input class="span2" id="prependedInput" name="prependedInput" size="16" type="text" value="" />
    </div>
    <p class="help-block">Here\'s some help text</p>
  </div>
</div>';
$rendered = $form->field('prependedInput')->render;
is_html( $rendered, $expected, 'prependedInput rendered ok' );

$expected =
'<div class="control-group">
  <label class="control-label" for="appendedInput">Appended text</label>
  <div class="controls">
    <div class="input-append">
      <input class="span2" id="appendedInput" name="appendedInput" size="16" type="text" value="" />
      <span class="add-on">.00</span>
    </div>
    <p class="help-block">Here\'s more help text</p>
  </div>
</div>';
$rendered = $form->field('appendedInput')->render;
is_html( $rendered, $expected, 'appendedinput rendered ok' );

$expected =
'<div class="control-group">
  <label class="control-label" for="inlineCheckboxes">Inline checkboxes</label>
  <div class="controls">
    <label class="checkbox inline" for="inlineCheckboxes.0">
      <input type="checkbox" id="inlineCheckboxes.0" name="inlineCheckboxes" value="option1"> 1
    </label>
    <label class="checkbox inline" for="inlineCheckboxes.1">
      <input type="checkbox" id="inlineCheckboxes.1" name="inlineCheckboxes" value="option2"> 2
    </label>
    <label class="checkbox inline" for="inlineCheckboxes.2">
      <input type="checkbox" id="inlineCheckboxes.2" name="inlineCheckboxes" value="option3"> 3
    </label>
  </div>
</div>';
$rendered = $form->field('inlineCheckboxes')->render;
is_html( $rendered, $expected, 'inlineCheckboxes rendered ok' );

$expected =
'<label class="checkbox" for="optionsCheckboxList1">
  <input type="checkbox" name="optionsCheckboxList1" id="optionsCheckboxList1" value="option1">
  Option one is this and that&mdash;be sure to include why it’s great
</label>';
$rendered = $form->field('optionsCheckboxList1')->render;
is_html( $rendered, $expected, 'optionsCheckboxList1 rendred ok by itself');

$expected =
'<div class="control-group">
  <label class="control-label">Checkboxes</label>
  <div class="controls">
    <label class="checkbox" for="optionsCheckboxList1">
      <input type="checkbox" name="optionsCheckboxList1" id="optionsCheckboxList1" value="option1">
      Option one is this and that&mdash;be sure to include why it’s great
    </label>
    <label class="checkbox" for="optionsCheckboxList2">
      <input type="checkbox" name="optionsCheckboxList2" id="optionsCheckboxList2" value="option2">
      Option two can also be checked and included in form results
    </label>
    <label class="checkbox" for="optionsCheckboxList3">
      <input type="checkbox" name="optionsCheckboxList3" id="optionsCheckboxList3" value="option3">
      Option three can&mdash;yes, you guessed it&mdash;also be checked and included in form results
    </label>
    <p class="help-text"><strong>Note:</strong> Labels surround all the options for much larger click areas and a more usable form.</p>
  </div>
</div>';
$rendered = $form->block('checkboxList')->render;
is_html( $rendered, $expected, 'checkbox group block renders ok' );

$expected =
'<div class="control-group">
  <label class="control-label" for="optionsRadios">Radio buttons</label>
  <div class="controls">
    <label class="radio" for="optionsRadios.0">
      <input type="radio" name="optionsRadios" id="optionsRadios.0" value="option1" />
      Option one is this and that&mdash;be sure to include why it’s great
    </label>
    <label class="radio" for="optionsRadios.1">
      <input type="radio" name="optionsRadios" id="optionsRadios.1" value="option2" />
      Option two can is something else and selecting it will deselect option one
    </label>
  </div>
</div>';
$rendered = $form->field('optionsRadios')->render;
is_html( $rendered, $expected, 'radio rendered ok' );

$expected =
'<div class="row">
  <div class="span8">
    <form class="form-horizontal">
      <fieldset>
        <legend>Extending form controls</legend>
        <div class="control-group">
          <label class="control-label">Form sizes</label>
          <div class="controls">
            <input id="text1" name="text1" class="span2" type="text" placeholder=".span2" value="" />
            <input id="text2" name="text2" class="span3" type="text" placeholder=".span3" value="" />
            <input id="text3" name="text3" class="span4" type="text" placeholder=".span4" value="" />
            <p class="help-block">Use the same <code>.span*</code> classes from the grid system for input sizes.</p>
          </div>
        </div>
        <div class="control-group">
          <label class="control-label" for="prependedInput">Prepended text</label>
          <div class="controls">
            <div class="input-prepend">
              <span class="add-on">@</span>
              <input class="span2" id="prependedInput" name="prependedInput" size="16" type="text" value="" />
            </div>
            <p class="help-block">Here\'s some help text</p>
          </div>
        </div>
        <div class="control-group">
          <label class="control-label" for="appendedInput">Appended text</label>
          <div class="controls">
            <div class="input-append">
              <input class="span2" id="appendedInput" name="appendedInput" size="16" type="text" value="" />
              <span class="add-on">.00</span>
            </div>
            <p class="help-block">Here\'s more help text</p>
          </div>
        </div>
        <div class="control-group">
          <label class="control-label" for="inlineCheckboxes">Inline checkboxes</label>
          <div class="controls">
            <label class="checkbox inline" for="inlineCheckboxes.0">
              <input type="checkbox" id="inlineCheckboxes.0" name="inlineCheckboxes" value="option1"> 1
            </label>
            <label class="checkbox inline" for="inlineCheckboxes.1">
              <input type="checkbox" id="inlineCheckboxes.1" name="inlineCheckboxes" value="option2"> 2
            </label>
            <label class="checkbox inline" for="inlineCheckboxes.2">
              <input type="checkbox" id="inlineCheckboxes.2" name="inlineCheckboxes" value="option3"> 3
            </label>
          </div>
        </div>
        <div class="control-group">
          <label class="control-label">Checkboxes</label>
          <div class="controls">
            <label class="checkbox" for="optionsCheckboxList1">
              <input type="checkbox" name="optionsCheckboxList1" id="optionsCheckboxList1" value="option1">
              Option one is this and that&mdash;be sure to include why it’s great
            </label>
            <label class="checkbox" for="optionsCheckboxList2">
              <input type="checkbox" name="optionsCheckboxList2" id="optionsCheckboxList2" value="option2">
              Option two can also be checked and included in form results
            </label>
            <label class="checkbox" for="optionsCheckboxList3">
              <input type="checkbox" name="optionsCheckboxList3" id="optionsCheckboxList3" value="option3">
              Option three can&mdash;yes, you guessed it&mdash;also be checked and included in form results
            </label>
            <p class="help-text"><strong>Note:</strong> Labels surround all the options for much larger click areas and a more usable form.</p>
          </div>
        </div>
        <div class="control-group">
          <label class="control-label" for="optionsRadios">Radio buttons</label>
          <div class="controls">
            <label class="radio" for="optionsRadios.0">
              <input type="radio" name="optionsRadios" id="optionsRadios.0" value="option1" />
              Option one is this and that&mdash;be sure to include why it’s great
            </label>
            <label class="radio" for="optionsRadios.1">
              <input type="radio" name="optionsRadios" id="optionsRadios.1" value="option2" />
              Option two can is something else and selecting it will deselect option one
            </label>
          </div>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Save changes</button>
          <button type="reset" class="btn">Cancel</button>
        </div>
      </fieldset>
    </form>
  </div>
</div>';

done_testing;
