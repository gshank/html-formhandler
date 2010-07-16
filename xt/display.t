use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar' => ( type => 'Display' );
    has_field 'baz' => ( type => 'Display' );

    sub html_bar {
        my ( $self, $field ) = @_;
        my $html = '<div><b>My Bar:&nbps;</b>' . $field->value . '</div>';
        return $html;
    }
    sub html_baz {
        my ( $self, $field ) = @_;
        my $html = '<div><b>My Baz:&nbps;</b>' . $field->value . '</div>';
        return $html;
    }
}

my $form = Test::Form->new;

my $init_obj = {
    foo => 'we have a foo',
    bar => '...and a bar...',
    baz => '...and a baz!!',
};

$form->process( init_object => $init_obj, params => {} );
my $rendered = $form->render;
like( $rendered, qr/and a bar/, 'value for display field renders' );
like( $rendered, qr/and a baz!!/, 'value for display field renders' );

# testing
$form->process( init_object => $init_obj, params => { foo => 'new foo' } );
$rendered = $form->render;
like( $rendered, qr/and a bar/, 'value for display field still renders' );
is_deeply( $form->value, { foo => 'new foo' }, 'value for form is correct' );
is_deeply( $form->fif, { foo => 'new foo' }, 'fif for form is correct' );




done_testing;
