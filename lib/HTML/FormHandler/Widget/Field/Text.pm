package HTML::FormHandler::Widget::Field::Text;

use Moose::Role;
use HTML::Entities;

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = '<input type="text" name="';
    $output .= $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= ' size="' . $self->size . '"' if $self->size;
    $output .= ' maxlength="' . $self->maxlength . '"' if $self->maxlength;
    $output .= ' value="' . encode_entities($result->fif) . '" />';
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
