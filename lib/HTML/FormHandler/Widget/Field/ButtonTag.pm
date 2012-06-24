package HTML::FormHandler::Widget::Field::ButtonTag;
# ABSTRACT: button field rendering widget, using button tag

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $output = '<button type="' . $self->input_type . '" name="'
        . $self->html_name . '" id="' . $self->id . '"';
    $output .= process_attrs($self->element_attributes($result));
    $output .= '>';
    $output .= $self->_localize($self->value);
    $output .= "</button>";
    return $output;
}

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}


1;
