package HTML::FormHandler::Widget::Field::Textarea;

use Moose::Role;
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $fif  = $self->html_filter($result->fif) || '';
    my $id   = $self->id;
    my $cols = $self->cols || 10;
    my $rows = $self->rows || 5;
    my $name = $self->html_name;

    my $output =
        qq(<textarea name="$name" id="$id" )
        . $self->_add_html_attributes
        . qq(rows="$rows" cols="$cols">)
        . $self->html_filter($fif)
        . q(</textarea>);

    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
