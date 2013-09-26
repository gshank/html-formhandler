use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

use_ok('HTML::FormHandler::Widget::Wrapper::Bootstrap3');

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_wrapper' => ( default => 'Bootstrap3' );
    has_field 'foo' => ( required => 1 );
    has_field 'bar';
    has_field 'active' => ( type => 'Checkbox' );
    has_field 'vegetables' => ( type => 'Multiple', widget => 'RadioGroup' );
    sub options_vegetables {
        return (
            1   => 'lettuce',
            2   => 'broccoli',
            3   => 'carrots',
            4   => 'peas',
        );
    }
    has_field 'save' => ( type => 'Submit', element_wrapper_class => ['col-lg-offset-2', 'col-lg-10'] );

}

my $form = MyApp::Form::Test->new;
ok( $form, 'form builds' );

my $expected = '
<div class="form-group">
  <label class="control-label" for="foo">Foo</label>
  <div>
    <input class="form-control" id="foo" name="foo" type="text" value="" />
  </div>
</div>
';
my $rendered = $form->field('foo')->render;
is_html( $rendered, $expected, 'foo renders ok' );

$expected = '
<div class="form-group">
  <div>
    <div class="checkbox">
      <label for="active">
        <input  id="active" name="active" type="checkbox" value="1" /> Active
      </label>
    </div>
  </div>
</div>
';
$rendered = $form->field('active')->render;
is_html( $rendered, $expected, 'checkbox renders ok' );

$expected = '
<div class="form-group">
  <div class="col-lg-offset-2 col-lg-10">
    <input id="save" name="save" type="submit" value="Save" />
  </div>
</div>
';
$rendered = $form->field('save')->render;
is_html( $rendered, $expected, 'submit button renders ok' );

$expected = '
<div class="form-group">
  <label class="control-label" for="vegetables">Vegetables</label>
  <div>
    <div class="radio">
      <label class="radio" for="vegetables.0">
        <input id="vegetables.0" name="vegetables" type="radio" value="1" />
        lettuce
      </label>
    </div>
    <div class="radio">
      <label class="radio" for="vegetables.1">
        <input id="vegetables.1" name="vegetables" type="radio" value="2" />
        broccoli
      </label>
    </div>
    <div class="radio">
      <label class="radio" for="vegetables.2">
        <input id="vegetables.2" name="vegetables" type="radio" value="3" />
        carrots
      </label>
    </div>
    <div class="radio">
      <label class="radio" for="vegetables.3">
        <input id="vegetables.3" name="vegetables" type="radio" value="4" />
        peas
      </label>
    </div>
  </div>
</div>
';
$rendered = $form->field('vegetables')->render;
is_html( $rendered, $expected, 'radio group renders' );

# after processing
$form->process( params => { bar => 'bar' } );

$expected = '
<div class="form-group has-error">
  <label class="control-label" for="foo">Foo</label>
  <div>
    <input class="has-error form-control" id="foo" name="foo" type="text" value="" />
    <span class="help-block">Foo field is required</span>
  </div>
</div>
';
$rendered = $form->field('foo')->render;
is_html( $rendered, $expected, 'foo renders ok with error' );



done_testing;
