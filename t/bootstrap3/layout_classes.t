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
    sub build_form_tags {{
        'layout_classes' => {
            label_class => ['col-lg-2'],
            element_wrapper_class => ['col-lg-10'],
            no_label_element_wrapper_class => ['col-lg-offset-2'],
        },
    }}
    has_field 'bar' => ( element_wrapper_class => ['col-lg-5'] );
    has_field 'foo' => ( type => 'Checkbox', do_label => 0, element_wrapper_class => ['col-lg-6'] );
    has_field 'save' => ( type => 'Submit' );

}

my $form = MyApp::Form::Test->new;
ok( $form, 'form builds' );


# after processing
$form->process( params => { bar => 'bar' } );

my $expected = '
<div class="form-group">
  <label class="col-lg-2 control-label" for="bar">Bar</label>
  <div class="col-lg-5">
    <input class="form-control" id="bar" name="bar" type="text" value="bar" />
  </div>
</div>
';
my $rendered = $form->field('bar')->render;
is_html( $rendered, $expected, 'bar renders ok' );

$expected = '
<div class="form-group">
  <div class="col-lg-6 col-lg-offset-2">
    <div class="checkbox">
      <label for="foo"><input id="foo" name="foo" type="checkbox" value="1" /> Foo </label>
    </div>
  </div>
</div>
';
$rendered = $form->field('foo')->render;
is_html( $rendered, $expected, 'foo renders ok' );


done_testing;
