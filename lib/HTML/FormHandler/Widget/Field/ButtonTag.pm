package HTML::FormHandler::Widget::Field::ButtonTag;
# ABSTRACT: button field rendering widget, using 'button tag

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

has 'no_render_label' => ( is => 'ro', isa => 'Bool', default => 1 );

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $t;

    my $rendered = $self->html_filter($result->fif);
    my $output = '<button type="' . $self->input_type . '" name="'
        . $self->html_name . '" id="' . $self->id . '"';
    $output .= process_attrs($self->attributes);
    $output .= '/>';
    $output .= $self->value;
    $output .= "</button>";

    return $self->wrap_field( $result, $output );
}

1;
