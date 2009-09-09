package HTML::FormHandler::Widget::Field::Checkbox;

use Moose::Role;

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $fif    = $result->fif;
    my $output = '<input type="checkbox" name="';
    $output .=
        $self->html_name . '" id="' . $self->id . '" value="' . $self->checkbox_value . '"';
    $output .= ' checked="checked"' if $fif eq $self->checkbox_value;
    $output .= ' />';
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
