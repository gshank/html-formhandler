use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( wrap_label_method => \&wrap_label );
    has_field 'bar';
    sub wrap_label {
        my $self = shift;
        my $name = $self->name;
        my $label = $self->label;
        return qq{<a href="/admin/history/$name">$label</a>};
    }
}

my $form = MyApp::Test::Form->new;
ok( $form );
is( $form->field('foo')->label, 'Foo', 'label is correct' );
is( $form->field('foo')->wrap_label, '<a href="/admin/history/foo">Foo</a>',
   'wrapped label is correct' );
my $rendered = $form->field('foo')->render;
my $expected = '<div><label for="foo"><a href="/admin/history/foo">Foo</a></label><input id="foo" name="foo" type="text" value="" /></div>';
is_html( $rendered, $expected, 'rendered ok' );

done_testing;
