use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'action_form' );
    has_field 'foo';
    has_field 'actions' => ( type => 'Compound', do_wrapper => 1 ,
        do_label => 0, wrapper_class => 'form-actions' );
    has_field 'actions.save' => ( type => 'Submit', widget_wrapper => 'None' );
    has_field 'actions.cancel' => ( type => 'Reset', widget_wrapper => 'None' );
}

my $form = Test::Form->new;
$form->process;
my $rendered = $form->render;
my $expected =
'<form id="action_form" method="post">
  <div class="form_messages"></div>
  <div>
    <label for="foo">Foo</label>
    <input id="foo" name="foo" type="text" value="" />
  </div>
  <div class="form-actions">
    <input id="actions.save" name="actions.save" type="submit" value="Save" />
    <input id="actions.cancel" name="actions.cancel" type="reset" value="Reset" />
  </div>
</form>';
is_html($rendered, $expected, 'actions render ok' );

done_testing;
