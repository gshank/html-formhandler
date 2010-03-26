package HTML::FormHandler::Widget::Field::RadioGroup;

use Moose::Role;

with 'HTML::FormHandler::Widget::Field::Role::SelectedOption';

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = " <br />";
    my $index  = 0;
    foreach my $option ( @{ $self->options } ) {
        $output .= '<input type="radio" value="' . $option->{value} . '"';
        $output .= ' name="' . $self->html_name . '" id="' . $self->id . ".$index\"";
        $output .= ' checked="checked"' if $self->check_selected_option($option, $result->fif);
        $output .= ' />';
        $output .= $option->{label} . '<br />';
        $index++;
    }
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
