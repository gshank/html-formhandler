package HTML::FormHandler::Widget::Field::Submit;
# ABSTRACT: submit field rendering widget
use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

Renders a submit field.

=cut

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $output = '<input type="submit" name="';
    $output .= $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= ' value="' . $self->html_filter($self->_localize($self->value)) . '"';
    $output .= process_attrs($self->element_attributes($result));
    $output .= ' />';
    return $output;
}

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

1;
