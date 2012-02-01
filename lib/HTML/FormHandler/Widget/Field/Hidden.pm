package HTML::FormHandler::Widget::Field::Hidden;
# ABSTRACT: hidden field rendering widget

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = "\n";
    $output .= '<input type="hidden" name="';
    $output .= $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= ' value="' . $self->html_filter($result->fif) . '"';
    $output .= process_attrs($self->element_attributes($result));
    $output .= " />\n";

    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
