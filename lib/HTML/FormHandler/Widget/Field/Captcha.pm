package HTML::FormHandler::Widget::Field::Captcha;
# ABSTRACT: Captcha field rendering widget
use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

Renderer for Captcha field

=cut

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    return '' if $self->widget eq 'no_widget';

    my $output = '<img src="' . $self->form->captcha_image_url . '"/>';
    $output .= '<input id="' . $self->id . '" name="';
    $output .= $self->html_name . '"';
    $output .= process_attrs($self->element_attributes);
    $output .= '/>';
    return $output;
}

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    die "No result for form field '" . $self->full_name . "'. Field may be inactive." unless $result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

1;
