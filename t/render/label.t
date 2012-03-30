use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    our $labels = {
        foo => 'My Foo',
        bar => 'My Bar',
    };

    has_field 'foo' => ( wrap_label_method => \&wrap_label,
        build_label_method => \&build_label,
    );
    has_field 'bar';
    sub build_label {
        my $self = shift; # self is field
        my $name = $self->name;
        return $labels->{$name};
    }
    sub wrap_label {
        my ( $self, $label ) = @_;
        $label ||= $self->label; # so it can be used outside of rendering...
        my $name = $self->name;
        return qq{<a href="/admin/history/$name">$label</a>};
    }
}

my $form = MyApp::Test::Form->new;
ok( $form );
is( $form->field('foo')->label, 'My Foo', 'label is correct' );
is( $form->field('foo')->wrap_label, '<a href="/admin/history/foo">My Foo</a>',
   'wrapped label is correct' );
my $rendered = $form->field('foo')->render;
my $expected = '<div><label for="foo"><a href="/admin/history/foo">My Foo</a></label><input id="foo" name="foo" type="text" value="" /></div>';
is_html( $rendered, $expected, 'rendered ok' );

done_testing;
