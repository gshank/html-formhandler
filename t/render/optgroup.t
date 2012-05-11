use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

# tests rendering an optgroup
{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'testop' => ( type => 'Select', multiple => 1, empty_select => '-- Choose --' );
    sub options_testop { (
        {
            group => 'First Group',
            options => [
                { value => 1, label => 'One' },
                { value => 2, label => 'Two' },
                { value => 3, label => 'Three' },
            ],
        },
        {
            group => 'Second Group',
            options => [
                { value => 4, label => 'Four' },
                { value => 5, label => 'Five' },
                { value => 6, label => 'Six' },
            ],
        },
        { value => '6a', label => 'SixA' },
        {
            group => 'Third Group',
            options => [
                { value => 7, label => 'Seven' },
                { value => 8, label => 'Eight' },
                { value => 9, label => 'Nine' },
            ],
        },

    ) }
}

my $form = MyApp::Form::Test->new;
ok( $form, 'form built' );
$form->process ( { foo => 'my_foo', testop => 12 } );
ok( ! $form->validated, 'form validated' );
my $params = { foo => 'my_foo', testop => 8 };

$form->process( $params );
ok( $form->validated, 'form validated' );
my $rendered = $form->field('testop')->render;
my $expected =
'<div><label for="testop">Testop</label>
<select name="testop" id="testop" multiple="multiple">
  <option value="" id="testop.0">-- Choose --</option>
  <optgroup label="First Group">
    <option value="1" id="testop.1">One</option>
    <option value="2" id="testop.2">Two</option>
    <option value="3" id="testop.3">Three</option>
  </optgroup>
  <optgroup label="Second Group">
    <option value="4" id="testop.4">Four</option>
    <option value="5" id="testop.5">Five</option>
    <option value="6" id="testop.6">Six</option>
  </optgroup>
  <option value="6a" id="testop.7">SixA</option>
  <optgroup label="Third Group">
    <option value="7" id="testop.8">Seven</option>
    <option value="8" id="testop.9" selected="selected">Eight</option>
    <option value="9" id="testop.10">Nine</option>
  </optgroup>
</select></div>';

is_html( $rendered, $expected, 'select rendered ok' );

$form = MyApp::Form::Test->new( update_subfields => { 'testop' => { widget => 'CheckboxGroup' } } );
$form->process( $params );
$rendered = $form->field('testop')->render;
$expected =
'<div>
  <label for="testop">Testop</label>
  <div>
    <label>First Group</label>
    <label class="checkbox" for="testop.0"><input id="testop.0" name="testop" type="checkbox" value="1" /> One </label>
    <label class="checkbox" for="testop.1"><input id="testop.1" name="testop" type="checkbox" value="2" /> Two </label>
    <label class="checkbox" for="testop.2"><input id="testop.2" name="testop" type="checkbox" value="3" /> Three </label>
  </div>
  <div>
    <label>Second Group</label>
    <label class="checkbox" for="testop.3"><input id="testop.3" name="testop" type="checkbox" value="4" /> Four </label>
    <label class="checkbox" for="testop.4"><input id="testop.4" name="testop" type="checkbox" value="5" /> Five </label>
    <label class="checkbox" for="testop.5"><input id="testop.5" name="testop" type="checkbox" value="6" /> Six </label>
  </div>
  <label class="checkbox" for="testop.6"><input id="testop.6" name="testop" type="checkbox" value="6a" /> SixA </label>
  <div>
    <label>Third Group</label>
    <label class="checkbox" for="testop.7"><input id="testop.7" name="testop" type="checkbox" value="7" /> Seven </label>
    <label class="checkbox" for="testop.8"><input checked="checked" id="testop.8" name="testop" type="checkbox" value="8" /> Eight </label>
    <label class="checkbox" for="testop.9"><input id="testop.9" name="testop" type="checkbox" value="9" /> Nine </label>
  </div>
</div>';

is_html( $rendered, $expected, 'checkboxgroup renders ok' );

$form = MyApp::Form::Test->new( update_subfields => { 'testop' => { widget => 'RadioGroup', multiple => 0 } } );
$form->process( $params );
$rendered = $form->field('testop')->render;
$expected =
'<div>
  <label for="testop">Testop</label>
  <div><label>First Group</label>
    <label class="radio" for="testop.0"><input id="testop.0" name="testop" type="radio" value="1" /> One </label>
    <label class="radio" for="testop.1"><input id="testop.1" name="testop" type="radio" value="2" /> Two </label>
    <label class="radio" for="testop.2"><input id="testop.2" name="testop" type="radio" value="3" /> Three </label>
  </div>
  <div>
    <label>Second Group</label>
    <label class="radio" for="testop.3"><input id="testop.3" name="testop" type="radio" value="4" /> Four </label>
    <label class="radio" for="testop.4"><input id="testop.4" name="testop" type="radio" value="5" /> Five </label>
    <label class="radio" for="testop.5"><input id="testop.5" name="testop" type="radio" value="6" /> Six </label>
  </div>
  <label class="radio" for="testop.6"><input id="testop.6" name="testop" type="radio" value="6a" /> SixA </label>
  <div>
    <label>Third Group</label>
    <label class="radio" for="testop.7"><input id="testop.7" name="testop" type="radio" value="7" /> Seven </label>
    <label class="radio" for="testop.8"><input checked="checked" id="testop.8" name="testop" type="radio" value="8" /> Eight </label>
    <label class="radio" for="testop.9"><input id="testop.9" name="testop" type="radio" value="9" /> Nine </label>
  </div>
</div>';
is_html( $rendered, $expected, 'radiogroup renders ok' );

done_testing;
