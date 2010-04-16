package HTML::FormHandler::Widget::Field::Checkbox;

use Moose::Role;
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $fif    = $result->fif;
    my $output = '<input type="checkbox" name="';
    $output .= $self->html_name . '" id="' . $self->id . '"';
    $output .= ' value="' . $self->html_filter($self->checkbox_value) . '"';
    $output .= ' checked="checked"' if $fif eq $self->checkbox_value;
    $output .= $self->_add_html_attributes;
    $output .= ' />';
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
