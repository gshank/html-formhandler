package HTML::FormHandler::Widget::Field::Text;
# ABSTRACT: text field rendering widget

use Moose::Role;
use namespace::autoclean;

with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $t;

    my $rendered = $self->html_filter($result->fif);
    my $output = '<input type="text" name="'
        . $self->html_name . '" id="' . $self->id . '"';
    $output .= qq{ size="$t"} if $t = $self->size;
    $output .= qq{ maxlength="$t"} if $t = $self->maxlength;
    $output .= ' value="' . $self->html_filter($result->fif) . '"';
    $output .= $self->_add_html_attributes;
    $output .= ' />';

    return $self->wrap_field( $result, $output );
}

1;
