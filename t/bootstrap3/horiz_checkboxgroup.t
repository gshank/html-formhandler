use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Widget::Theme::Bootstrap3';

    sub build_form_tags {
        {
            'layout_classes' => {
                label_class                    => ['col-lg-2'],
                element_wrapper_class          => ['col-lg-10'],
                no_label_element_wrapper_class => ['col-lg-offset-2'],
            },
        }
    }

    has_field 'checkboxes' => (
        type   => 'Multiple',
        widget => 'CheckboxGroup',
    );
    sub options_checkboxes {
        return (
            1 => 'tag1',
            2 => 'tag2',
            3 => 'tag3',
            4 => 'tag4',
        );
    }
}

my $form = MyApp::Form::Test->new;
$form->process;

my $expected = '
<div class="form-group">
  <label class="col-lg-2 control-label" for="checkboxes">Checkboxes</label>
  <div class="col-lg-10">
    <div class="checkbox">
      <label for="checkboxes.0">
        <input id="checkboxes.0" name="checkboxes" type="checkbox" value="1" />
        tag1
      </label>
    </div>
    <div class="checkbox">
      <label for="checkboxes.1">
        <input id="checkboxes.1" name="checkboxes" type="checkbox" value="2" />
        tag2
      </label>
    </div>
    <div class="checkbox">
      <label for="checkboxes.2">
        <input id="checkboxes.2" name="checkboxes" type="checkbox" value="3" />
        tag3
      </label>
    </div>
    <div class="checkbox">
      <label for="checkboxes.3">
        <input id="checkboxes.3" name="checkboxes" type="checkbox" value="4" />
        tag4
      </label>
    </div>
  </div>
</div>
';

is_html( $form->field('checkboxes')->render, $expected, 'checkbox group rendered ok' );

done_testing;
