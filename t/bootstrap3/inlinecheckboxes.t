use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_wrapper' => ( default => 'Bootstrap3');
	sub build_form_tags {{
	'layout_classes' => {
		label_class => ['col-lg-2'],
		element_wrapper_class => ['col-lg-10'],
		no_label_element_wrapper_class => ['col-lg-offset-2'],
	},
    }}
	has_field 'Checkboxes' => (
        type => 'Compound',
        do_wrapper => 1,
        do_label => 1,
	);
	has_field 'Checkboxes.option1' => (
        type => 'Checkbox',
        do_wrapper => 0,
        do_label => 0,
        tags => { 'inline' => 1 },
	);
	has_field 'Checkboxes.option2' => (
        type => 'Checkbox',
        do_wrapper => 0,
        do_label => 0,
        tags => { 'inline' => 1 },
	);
	has_field 'Checkboxes.option3' => (
        type => 'Checkbox',
        do_wrapper => 0,
        do_label => 0,
        tags => { 'inline' => 1 },
	);
}

my $form = MyApp::Form::Test->new;
$form->process;

my $expected = '
<div class="form-group" id="Checkboxes">
	<label class="col-lg-2 control-label" for="Checkboxes">Checkboxes</label>
	<div class="col-lg-10">
		<label class="checkbox-inline"  for="Checkboxes.option1">
			<input type="checkbox" name="Checkboxes.option1" id="Checkboxes.option1" value="1" />
			Option1
		</label>
		<label class="checkbox-inline"  for="Checkboxes.option2">
			<input type="checkbox" name="Checkboxes.option2" id="Checkboxes.option2" value="1" />
			Option2
		</label>
		<label class="checkbox-inline"  for="Checkboxes.option3">
			<input type="checkbox" name="Checkboxes.option3" id="Checkboxes.option3" value="1" />
			Option3
		</label>
	</div>
</div>
';

is_html( $form->field('Checkboxes')->render, $expected, 'inline checkboxes rendered ok' );

done_testing;
