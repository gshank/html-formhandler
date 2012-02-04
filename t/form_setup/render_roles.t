use strict;
use warnings;
use Test::More;

{
    package Test::Render;
    use Moose::Role;

    sub render {
        my $self = shift;
        my $output .= $self->render_start;
        $output .= '<p>This is the rendering role</p>';
        $output .= $self->render_end;
    }
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'Test::Render';

    has_field 'foo';
    has_field 'bar';
}

my $form = Test::Form->new;
my $render = $form->render;
like( $render, qr/This is the rendering role/, 'rendered using role' );
like( $render, qr/<form/, 'form tag rendered' );

done_testing;
