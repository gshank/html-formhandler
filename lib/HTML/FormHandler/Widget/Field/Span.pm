package HTML::FormHandler::Widget::Field::Span;
# ABSTRACT: button field rendering widget

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');
use namespace::autoclean;

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = '<span';
    $output .= ' id="' . $self->id . '"';
    $output .= process_attrs($self->element_attributes($result));
    $output .= ' />';
    $output .= $self->value;
    $output .= '</span>';
    return $self->wrap_field( $result, $output );
}

1;
