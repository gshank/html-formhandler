use strict;
use warnings;
use Test::More;

{
    package Test::Form::Theme;
    use Moose::Role;

    sub build_widget_tags {{
        form_tag => 1,
        some_tag => 1,
        field_tag => 0,
    }}
    sub build_update_fields {{
        foo => { element_class => ['interesting'] }
    }}
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'Test::Form::Theme';

    has_field 'foo' => ( element_class => ['fld_def'] );
    has_field 'bar' => ( widget_tags => { field_tag => 1 } );
    has_field 'rox' => ( wrapper_class => 'frmwrp' );

}

my $form = Test::Form->new;
ok( $form );
my $element_class = $form->field('foo')->element_class;
is_deeply( $element_class, ['interesting', 'fld_def'], 'got both classes' );
is_deeply( $form->field('bar')->widget_tags,
    { some_tag => 1, field_tag => 1 }, 'correct widget tags' );

done_testing;
