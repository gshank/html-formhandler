use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = 'en_en';
{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_form_wrapper_class { 'form_wrapper' }
    sub build_do_form_wrapper {1}
    sub build_update_subfields {{ all => { do_wrapper => 1, tags => { label_after => ': '} } }}
    has '+name' => ( default => 'test_errors' );
    has_field 'foo' => ( required => 1 );
    has_field 'bar' => ( type => 'Integer' );

}

#my $form = Test::Form->new( form_wrapper_attr => { class => 'form_wrapper' } );;
my $form = Test::Form->new;
$form->process( params => { bar => 'abc' } );

is( $form->num_errors, 2, 'got two errors' );

my $expected =
'<form id="test_errors" method="post">
  <fieldset class="form_wrapper">
  <div class="form_messages"></div>
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
</fieldset></form>';

my $rendered = $form->render;

is_html($rendered, $expected, 'html matches' );

{
    package Test::Compound;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'fringe' => ( type => 'Compound', do_wrapper => 1 );
    has_field 'fringe.olivia';
    has_field 'fringe.fauxlivia';

    sub validate_fringe_fauxlivia {
        my ( $self, $field ) = @_;
        $field->add_error('Wrong Olivia');
    }
}

$form = Test::Compound->new;
my $params = {
    'fringe.olivia' => "I'm the true Olivia",
    'fringe.fauxlivia' => "I'm the true Olivia",
};
$form->process( params => $params );
$rendered = $form->field('fringe.fauxlivia')->render;
$expected =
'<div class="error">
  <label for="fringe.fauxlivia">Fauxlivia</label>
  <input type="text" name="fringe.fauxlivia" id="fringe.fauxlivia" value="I\'m the true Olivia" class="error" />
  <span class="error_message">Wrong Olivia</span>
</div>';
is_html( $rendered, $expected, 'error on compound subfield has error class' );

$expected =
'<div class="error">
  <div>
    <label for="fringe.olivia">Olivia</label>
    <input type="text" name="fringe.olivia" id="fringe.olivia" value="I\'m the true Olivia" />
  </div>
  <div class="error">
    <label for="fringe.fauxlivia">Fauxlivia</label>
    <input type="text" name="fringe.fauxlivia" id="fringe.fauxlivia" value="I\'m the true Olivia" class="error" />
    <span class="error_message">Wrong Olivia</span>
  </div>
</div>';
$rendered = $form->field('fringe')->render;
is_html( $rendered, $expected, 'error on compound wrapper' );

done_testing;
