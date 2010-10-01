package HTML::FormHandler::Widget::Field::RadioGroup;
# ABSTRACT: radio group rendering widget

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
        $output .= qq{<label for="$id.$index"><input type="radio" value="}
            . $self->html_filter($option->{value}) . '" name="'
            . $self->html_name . qq{" id="$id.$index"};
        $output .= ' checked="checked"'
            if $self->check_selected_option($option, $result->fif);
        $output .= ' />';
        $output .= $self->html_filter($option->{label}) . '</label><br />';
        $index++;
    }
    return $self->wrap_field( $result, $output );
}

1;
