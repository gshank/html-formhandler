package HTML::FormHandler::Widget::Field::Password;

use Moose::Role;
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = '<input type="password" name="';
    $output .= $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= ' size="' . $self->size . '"' if $self->size;
    $output .= ' maxlength="' . $self->maxlength . '"' if $self->maxlength;
    $output .= ' value="' . $self->html_filter($result->fif) . '"';
    $output .= $self->_add_html_attributes;
    $output .= ' />';
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
