package HTML::FormHandler::Widget::Field::Textarea;

use Moose::Role;
use HTML::Entities;
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $fif  = encode_entities($result->fif) || '';
    my $id   = $self->id;
    my $cols = $self->cols || 10;
    my $rows = $self->rows || 5;
    my $name = $self->html_name;

    my $output =
        qq(<textarea name="$name" id="$id" )
        . $self->_add_html_attributes
        . qq(rows="$rows" cols="$cols">)
        . encode_entities($fif)
        . q(</textarea>);

    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
