use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'opt_in'     => (
        type    => 'Select',
        widget  => 'RadioGroup',
        options => [
            { value => 'no & never', label => 'No & Never', },
            { value => '"yes"', label => 'Yes' },
        ]
    );

    has_field 'option_group' => (
        type    => 'Select',
        widget  => 'RadioGroup',
        options => [
            {
                group            => 'First Group',
                options          => [ { value => 1, label => 'Yes'}, {value => 2, label => 'No' } ],
                attributes       => { class => 'firstgroup' },
                label_attributes => { class => 'group1' },
            }
        ]
    )
}

my $form = Test::Form->new;
$form->process;
my $expected =
'<div>
  <label for="opt_in">Opt in</label>
  <label class="radio" for="opt_in.0">
    <input type="radio" value="no &amp; never" name="opt_in" id="opt_in.0" />
    No &amp; Never
   </label>
  <label class="radio" for="opt_in.1">
    <input type="radio" value="&quot;yes&quot;" name="opt_in" id="opt_in.1" />
    Yes
  </label>
</div>';

my $rendered = $form->field('opt_in')->render;
is_html( $rendered, $expected, 'radio group rendered ok' );

my $params = {
    opt_in             => 'no & never',
};
$form->process( update_field_list => { opt_in => { tags => { 'radio_br_after' => 1 }}}, params => $params);
$rendered = $form->field('opt_in')->render;
$expected =
'<div>
  <label for="opt_in">Opt in</label><br />
  <label class="radio" for="opt_in.0">
    <input type="radio" value="no &amp; never" name="opt_in" id="opt_in.0" checked="checked" />
    No &amp; Never
  </label><br />
  <label class="radio" for="opt_in.1"><input type="radio" value="&quot;yes&quot;" name="opt_in" id="opt_in.1" />
    Yes
  </label><br />
</div>';

is_html( $rendered, $expected, 'output from radio group');

# option group attributes
$rendered = $form->field('option_group')->render;
$expected =
'<div>
  <label for="option_group">Option group</label>
  <div class="firstgroup">
    <label class="group1">First Group</label>
    <label class="radio" for="option_group.0">
      <input type="radio" value="1" name="option_group" id="option_group.0" />
      Yes
    </label>
    <label class="radio" for="option_group.1">
      <input type="radio" value="2" name="option_group" id="option_group.1" />
      No
    </label>
  </div>
</div>';

is_html( $rendered, $expected, 'output from ragio group with option group and label attributes');

# create form with no label rendering for opt_in
$form = Test::Form->new( field_list => [ '+opt_in' => { do_label => 0 } ] );
$form->process;
# first individually rendered option
$rendered = $form->field('opt_in')->render_option({ value => 'test', label => 'Test'});
$expected = '<label class="radio" for="opt_in.0"><input id="opt_in.0" name="opt_in" type="radio" value="test" /> Test </label>';
is_html( $rendered, $expected, 'individual option rendered ok' );
# second rendered option is wrapped
$rendered = $form->field('opt_in')->render_wrapped_option({ value => 'abcde', label => 'Abcde' });
$expected = '<div><label class="radio" for="opt_in.1"><input id="opt_in.1" name="opt_in" type="radio" value="abcde" /> Abcde </label></div>';
is_html( $rendered, $expected, 'indvidual wrapped option rendered ok' );

done_testing;
