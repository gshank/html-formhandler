use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Form::Theme;
    use Moose::Role;

    sub build_form_tags {{
        form_tag => 1,
    }}
    sub build_update_subfields {{
        all => { tags => { some_tag => 1, field_tag => 0 } },
        foo => { element_class => ['interesting'] }
    }}
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'Test::Form::Theme';

    has_field 'foo' => ( element_class => ['fld_def'] );
    has_field 'bar' => ( tags => { field_tag => 1 } );
    has_field 'rox' => ( wrapper_class => 'frmwrp' );

}

my $form = Test::Form->new;
ok( $form );
my $element_class = $form->field('foo')->element_class;
is_deeply( $element_class, ['interesting', 'fld_def'], 'got both classes' );
is_deeply( $form->field('rox')->tags, { some_tag => 1, field_tag => 0 }, 'correct widget tags' );
is_deeply( $form->field('bar')->tags,
    { some_tag => 1, field_tag => 1 }, 'correct widget tags' );

{
    package Test::ClassForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'hfhform' );
    sub build_update_subfields {{
        all => { wrapper_class => 'hfh' }
    }}
    has_field 'foo';
    has_field 'bar';
    has_field 'nox';

}

$form = Test::ClassForm->new;
$form->process;
is_deeply( $form->field('foo')->wrapper_class, ['hfh'], 'foo has class' );
is_deeply( $form->field('bar')->wrapper_class, ['hfh'], 'bar has class' );
is_deeply( $form->field('nox')->wrapper_class, ['hfh'], 'nox has class' );
my $rendered = $form->render;
my $expected =
'<form id="hfhform" method="post">
  <div class="form_messages"></div>
  <div class="hfh">
      <label for="foo">Foo</label>
      <input type="text" id="foo" name="foo" value="">
  </div>
  <div class="hfh">
      <label for="bar">Bar</label>
      <input type="text" id="bar" name="bar" value="">
  </div>
  <div class="hfh">
      <label for="nox">Nox</label>
      <input type="text" id="nox" name="nox" value="">
  </div>
</form>';
is_html( $rendered, $expected, 'rendered correctly' );

{
    package Test::ElementClassField;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Text';

    sub build_element_class { ['foo'] }
}
{
    package Test::ElementClassForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => (
        type          => '+Test::ElementClassField',
        element_class => 'bar',
    );

    # Note: all => { element_class => 'baz' } does not
    # override the specific setting on the field. This is
    # deliberate. The idea is that the more specific setting
    # should override the general setting. Like all of these things,
    # sometimes people are going to want it one way and sometimes the
    # other. If you want to set the element_class for all elements
    # at once, don't put a specific element_class on the field.
    sub build_update_subfields {
    {
        foo => { element_class => 'baz' },
    }
};
}
$form = Test::ElementClassForm->new;
$form->process;
is_deeply( $form->field('foo')->element_class, [qw( baz )], 'foo has correct classes' );

done_testing;
