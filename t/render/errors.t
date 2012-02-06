use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = HTML::FormHandler::I18N->get_handle('en_en');
{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_widget_tags { { form_wrapper => 1, label_after => ': ' } }
    sub build_form_wrapper_class { 'form_wrapper' }
    has '+name' => ( default => 'test_errors' );
    has_field 'foo' => ( required => 1 );
    has_field 'bar' => ( type => 'Integer' );

}

#my $form = Test::Form->new( form_wrapper_attr => { class => 'form_wrapper' } );;
my $form = Test::Form->new;
$form->process( params => { bar => 'abc' } );

is( $form->num_errors, 2, 'got two errors' );

my $expected =
'<fieldset class="form_wrapper">
  <form id="test_errors" method="post">
  <div class="error">
    <label for="foo">Foo: </label>
    <input class="error" type="text" name="foo" id="foo" value="" />
    <span class="error_message">Foo field is required</span>
  </div>
  <div class="error">
    <label for="bar">Bar: </label>
    <input class="error" type="text" name="bar" id="bar" size="8" value="abc" />
    <span class="error_message">Value must be an integer</span>
  </div>
</form></fieldset>';

my $rendered = $form->render;

is_html($rendered, $expected, 'html matches' );

done_testing;
