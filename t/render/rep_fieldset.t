use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

# this renders repeatable instances with a fieldset wrapper
{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test_form' );
    has_field 'records' => ( type => 'Repeatable', num_when_empty => 2,
        init_contains => { tags => { wrapper_tag => 'fieldset' } } );
    has_field 'records.one';
    has_field 'records.two';
}

my $form = Test::Form->new;
$form->process( params => {} );
my $rendered = $form->render;
my $expected =
'<form id="test_form" method="post">
  <div class="form_messages">
  </div>
  <fieldset class="hfh-repinst" id="records.0">
    <div>
      <label for="records.0.one">One</label>
      <input type="text" name="records.0.one" id="records.0.one" value="" />
    </div>
    <div>
      <label for="records.0.two">Two</label>
      <input type="text" name="records.0.two" id="records.0.two" value="" />
    </div>
  </fieldset>
  <fieldset class="hfh-repinst" id="records.1">
    <div>
      <label for="records.1.one">One</label>
      <input type="text" name="records.1.one" id="records.1.one" value="" />
    </div>
    <div>
      <label for="records.1.two">Two</label>
      <input type="text" name="records.1.two" id="records.1.two" value="" />
    </div>
  </fieldset>
</form>';
is_html( $rendered, $expected, 'rendered repeatable instances with fieldset' );

# tests setting repeatable instance wrapper to fieldset with update_subfields
{
    package Test::Form2;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test_form' );
    sub build_update_subfields { { by_flag => {
        repeatable => { init_contains => { tags => { wrapper_tag => 'fieldset' }}}}}}
    has_field 'records' => ( type => 'Repeatable', num_when_empty => 2 );
    has_field 'records.one';
    has_field 'records.two';
}

$form = Test::Form2->new;
$form->process;
$rendered = $form->render;
$expected =
'<form id="test_form" method="post">
  <div class="form_messages">
  </div>
  <fieldset class="hfh-repinst" id="records.0">
    <div>
      <label for="records.0.one">One</label>
      <input type="text" name="records.0.one" id="records.0.one" value="" />
    </div>
    <div>
      <label for="records.0.two">Two</label>
      <input type="text" name="records.0.two" id="records.0.two" value="" />
    </div>
  </fieldset>
  <fieldset class="hfh-repinst" id="records.1">
    <div>
      <label for="records.1.one">One</label>
      <input type="text" name="records.1.one" id="records.1.one" value="" />
    </div>
    <div>
      <label for="records.1.two">Two</label>
      <input type="text" name="records.1.two" id="records.1.two" value="" />
    </div>
  </fieldset>
</form>';
is_html( $rendered, $expected, 'setting wrapper_tag to fieldset using by_flag works' );

done_testing;
