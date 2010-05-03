package HTML::FormHandler::Widget::Field::RadioGroup;

use Moose::Role;
use namespace::autoclean;

with 'HTML::FormHandler::Widget::Field::Role::SelectedOption';

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $id = $self->id;
    my $output = " <br />";
    my $index  = 0;

    foreach my $option ( @{ $self->options } ) {
        $output .= '<input type="radio" value="'
            . $self->html_filter($option->{value}) . '" name="'
            . $self->html_name . qq{" id="$id.$index"};
        $output .= ' checked="checked"'
            if $self->check_selected_option($option, $result->fif);
        $output .= ' />';
        $output .= $self->html_filter($option->{label}) . '<br />';
        $index++;
    }
    return $self->wrap_field( $result, $output );
}

1;
