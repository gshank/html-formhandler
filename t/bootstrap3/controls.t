use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_wrapper' => ( default => 'Bootstrap3');
    has_field 'foo';
    has_field 'inlineCheckboxes' => ( type => 'Multiple', widget => 'CheckboxGroup',
        label => 'Inline checkboxes',
        tags => { 'inline' => 1 }, options => [ { value => 'option1', label => '1' },
            { value => 'option2', label => '2' }, { value => 'option3', label => '3' } ],
    );

}

my $form = MyApp::Form::Test->new;
$form->process;

my $expected = '
<div class="form-group">
  <label class="control-label" for="inlineCheckboxes">Inline checkboxes</label>
  <div>
    <label class="checkbox checkbox-inline" for="inlineCheckboxes.0"><input id="inlineCheckboxes.0" name="inlineCheckboxes" type="checkbox" value="option1" /> 1 </label>
    <label class="checkbox checkbox-inline" for="inlineCheckboxes.1"><input id="inlineCheckboxes.1" name="inlineCheckboxes" type="checkbox" value="option2" /> 2 </label>
    <label class="checkbox checkbox-inline" for="inlineCheckboxes.2"><input id="inlineCheckboxes.2" name="inlineCheckboxes" type="checkbox" value="option3" /> 3 </label>
  </div>
</div>
';

is_html( $form->field('inlineCheckboxes')->render, $expected, 'inline checkboxes rendered ok' );

done_testing;
