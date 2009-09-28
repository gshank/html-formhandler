package HTML::FormHandler::Widget::Field::Hidden;

use Moose::Role;
use HTML::Entities;

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = "\n";
    $output .= '<input type="hidden" name="';
    $output .= $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= ' value="' . encode_entities($result->fif) . '" />';
    $output .= "\n";

    return $output;
}

use namespace::autoclean;
1;
