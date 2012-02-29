package HTML::FormHandler::Widget::Field::ButtonTag;
# ABSTRACT: button field rendering widget, using 'button tag

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $t;

    my $output = '<button type="' . $self->input_type . '" name="'
        . $self->html_name . '" id="' . $self->id . '"';
    $output .= process_attrs($self->element_attributes($result));
    $output .= '>';
    $output .= $self->_localize($self->value);
    $output .= "</button>";

    return $self->wrap_field( $result, $output );
}

1;
