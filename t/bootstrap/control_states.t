use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::CtrlStates::Theme;
    use Moose::Role;
    with 'HTML::FormHandler::Widget::Theme::Bootstrap';

    sub build_form_tags {{
        after_start => '<fieldset><legend>Form control states</legend>',
        before_end => '</fieldset>',
    }}

    sub build_update_subfields {{
        focusedInput => { element_class => ['input-xlarge', 'focused'] },
        disabledInput => { element_class => ['input-xlarge'],
            element_attr => { placeholder => 'Disabled input here…' } },
        optionsCheckbox2 => { element_class => ['checkbox'],
            option_label => 'This is a disabled checkbox' },
        inputError3 => { wrapper_class => ['success'],
            tags => { after_element => qq{\n<span class="help-inline">Woohoo!</span>} } },
        selectError => { wrapper_class => ['success'],
            tags => { after_element => qq{\n<span class="help-inline">Woohoo!</span>} } },
        form_actions => { do_wrapper => 1, do_label => 0 },
        'form_actions.save' => { widget_wrapper => 'None', element_class => ['btn', 'btn-primary'] },
        'form_actions.cancel' => { widget_wrapper => 'None', element_class => ['btn'] },
    }}
}

{
    package MyApp::Form::CtrlStates;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'MyApp::Form::CtrlStates::Theme';

    has '+name' => ( default => 'test_form' );
    has_field 'focusedInput' => ( default => 'This is focused…', label => 'Focused input' );
    has_field 'disabledInput' => ( disabled => 1, label => 'Disabled input' );
    has_field 'optionsCheckbox2' => ( type => 'Checkbox', checkbox_value => "option1",
        disabled => 1, label => 'Disabled checkbox' );
    has_field 'inputError1' => ( validate_method => \&validate_ie1,
        label => 'Input with warning' );
    has_field 'inputError2' => ( validate_method => \&validate_ie2,
        label => 'Input with error' );;
    has_field 'inputError3' => ( label => 'Input with success' );;
    has_field 'selectError' => ( type => 'Select', label => 'Select with success',
        options => [{ value => 1, label => '1' }, { value => 2, label => '2' },
            { value => 3, label => '3'},
            { value => 4, label => '4' }, { value => 5, label => '5' } ],
    );
    has_field 'form_actions' => ( type => 'Compound' );
    has_field 'form_actions.save' => ( widget => 'ButtonTag', type => 'Submit',
        value => 'Save changes' );
    has_field 'form_actions.cancel' => ( widget => 'ButtonTag', type => 'Reset',
        value => 'Cancel' );
    sub validate_ie1 {
        my $self = shift; # self is the field here
        $self->add_warning('Something may have gone wrong');
    }
    sub validate_ie2 {
        my $self = shift;
        $self->add_error('Please correct the error');
    }
}

my $form = MyApp::Form::CtrlStates->new;

my $params = $form->fif;
$params->{inputError1} = 'entry';
$params->{inputError2} = 'xxx';
$params->{inputError3} = 'success';
$form->process( $params );

my $expected =
'<div class="control-group">
  <label class="control-label" for="focusedInput">Focused input</label>
  <div class="controls">
    <input class="input-xlarge focused" id="focusedInput" name="focusedInput" type="text" value="This is focused…" />
  </div>
</div>';
my $rendered = $form->field('focusedInput')->render;
is_html( $rendered, $expected, 'focusedInput field renders ok' );

$expected =
'<div class="control-group">
  <label class="control-label" for="disabledInput">Disabled input</label>
  <div class="controls">
    <input class="input-xlarge disabled" id="disabledInput" name="disabledInput" type="text" placeholder="Disabled input here…" disabled="disabled" value="" />
  </div>
</div>';
$rendered = $form->field('disabledInput')->render;
is_html( $rendered, $expected, 'disabledInput field renders ok' );

$expected =
'<div class="control-group">
  <label class="control-label" for="optionsCheckbox2">Disabled checkbox</label>
  <div class="controls">
    <label class="checkbox" for="optionsCheckbox2">
      <input class="checkbox disabled" type="checkbox" id="optionsCheckbox2" name="optionsCheckbox2" value="option1" disabled="disabled" />
      This is a disabled checkbox
    </label>
  </div>
</div>';
$rendered = $form->field('optionsCheckbox2')->render;
is_html( $rendered, $expected, 'optionsCheckbox2 renders ok');

$expected =
'<div class="control-group warning">
  <label class="control-label" for="inputError1">Input with warning</label>
  <div class="controls">
    <input class="warning" type="text" id="inputError1" name="inputError1" value="entry" />
    <span class="help-inline">Something may have gone wrong</span>
  </div>
</div>';
$rendered = $form->field('inputError1')->render;
is_html( $rendered, $expected, 'inputError1 renders ok' );

$expected =
'<div class="control-group error">
  <label class="control-label" for="inputError2">Input with error</label>
  <div class="controls">
    <input class="error" type="text" id="inputError2" name="inputError2" value="xxx" />
    <span class="help-inline">Please correct the error</span>
  </div>
</div>';
$rendered = $form->field('inputError2')->render;
is_html( $rendered, $expected, 'inputError2 renders ok' );

# this doesn't come from actual processing; could add something to set
$expected =
'<div class="control-group success">
  <label class="control-label" for="inputError3">Input with success</label>
  <div class="controls">
    <input type="text" id="inputError3" name="inputError3" value="success" />
    <span class="help-inline">Woohoo!</span>
  </div>
</div>';
$rendered = $form->field('inputError3')->render;
is_html( $rendered, $expected, 'inputError3 renders ok' );

$expected =
'<div class="control-group success">
  <label class="control-label" for="selectError">Select with success</label>
  <div class="controls">
    <select id="selectError" name="selectError">
      <option value="1" id="selectError.0">1</option>
      <option value="2" id="selectError.1">2</option>
      <option value="3" id="selectError.2">3</option>
      <option value="4" id="selectError.3">4</option>
      <option value="5" id="selectError.4">5</option>
    </select>
    <span class="help-inline">Woohoo!</span>
  </div>
</div>';
$rendered = $form->field('selectError')->render;
is_html( $rendered, $expected, 'selectError rendered ok' );

$expected =
'<div class="form-actions">
  <button type="submit" class="btn btn-primary" name="form_actions.save" id="form_actions.save">Save changes</button>
  <button type="reset" class="btn" name="form_actions.cancel" id="form_actions.cancel">Cancel</button>
</div>';

$rendered = $form->field('form_actions')->render;
is_html( $rendered, $expected, 'form_actions rendered ok' );

$expected =
'<form id="test_form" class="form-horizontal" method="post">
<fieldset>
  <legend>Form control states</legend>
  <div class="alert alert-error"><span class="error_message">There were errors in your form</span></div>
  <div class="control-group">
    <label class="control-label" for="focusedInput">Focused input</label>
    <div class="controls">
      <input class="input-xlarge focused" id="focusedInput" name="focusedInput" type="text" value="This is focused…" />
    </div>
  </div>
  <div class="control-group">
    <label class="control-label" for="disabledInput">Disabled input</label>
    <div class="controls">
      <input class="input-xlarge disabled" id="disabledInput" name="disabledInput" type="text" placeholder="Disabled input here…" disabled="disabled" value="" />
    </div>
  </div>
  <div class="control-group">
    <label class="control-label" for="optionsCheckbox2">Disabled checkbox</label>
    <div class="controls">
      <label class="checkbox" for="optionsCheckbox2">
        <input class="checkbox disabled" type="checkbox" id="optionsCheckbox2" name="optionsCheckbox2" value="option1" disabled="disabled" />
        This is a disabled checkbox
      </label>
    </div>
  </div>
  <div class="control-group warning">
    <label class="control-label" for="inputError1">Input with warning</label>
    <div class="controls">
      <input class="warning" type="text" id="inputError1" name="inputError1" value="entry" />
      <span class="help-inline">Something may have gone wrong</span>
    </div>
  </div>
  <div class="control-group error">
    <label class="control-label" for="inputError2">Input with error</label>
    <div class="controls">
      <input class="error" type="text" id="inputError2" name="inputError2" value="xxx" />
      <span class="help-inline">Please correct the error</span>
    </div>
  </div>
  <div class="control-group success">
    <label class="control-label" for="inputError3">Input with success</label>
    <div class="controls">
      <input type="text" id="inputError3" name="inputError3" value="success" />
      <span class="help-inline">Woohoo!</span>
    </div>
  </div>
  <div class="control-group success">
    <label class="control-label" for="selectError">Select with success</label>
    <div class="controls">
      <select id="selectError" name="selectError">
        <option value="1" id="selectError.0">1</option>
        <option value="2" id="selectError.1">2</option>
        <option value="3" id="selectError.2">3</option>
        <option value="4" id="selectError.3">4</option>
        <option value="5" id="selectError.4">5</option>
      </select>
      <span class="help-inline">Woohoo!</span>
    </div>
  </div>
  <div class="form-actions">
    <button type="submit" class="btn btn-primary" name="form_actions.save" id="form_actions.save">Save changes</button>
    <button type="reset" class="btn" name="form_actions.cancel" id="form_actions.cancel">Cancel</button>
  </div>
</fieldset>
</form>';

$rendered = $form->render;
is_html( $rendered, $expected, 'form rendered ok' );

done_testing;
