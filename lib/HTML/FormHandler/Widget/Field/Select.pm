package HTML::FormHandler::Widget::Field::Select;

use Moose::Role;
use namespace::autoclean;

with 'HTML::FormHandler::Widget::Field::Role::SelectedOption';
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $id = $self->id;
    my $index = 0;
    my $multiple = $self->multiple;
    my $output = '<select name="' . $self->html_name . qq{" id="$id"};
    my $t;

    $output .= ' multiple="multiple"' if $multiple;
    $output .= qq{ size="$t"} if $t = $self->size;
    $output .= $self->_add_html_attributes;
    $output .= '>';

    $t = $self->empty_select
        and $output .= qq{<option value="">$t</option>};

    foreach my $option ( @{ $self->{options} } ) {
        $output .= '<option value="'
            . $self->html_filter($option->{value})
            . qq{" id="$id.$index"};
        if ( my $ffif = $result->fif ) {
            if ( $multiple ) {
                my @fif;
                if ( ref $ffif ) {
                    @fif = @{$ffif};
                }
                else {
                    @fif = ($ffif);
                }
                foreach my $optval (@fif) {
                    $output .= ' selected="selected"'
                        if $self->check_selected_option($option, $optval);
                }
            }
            else {
                $output .= ' selected="selected"'
                    if $self->check_selected_option($option, $ffif);
            }
        }
        $output .= ' selected="selected"'
            if $self->check_selected_option($option);
        $output .= '>' . $self->html_filter($option->{label}) . '</option>';
        $index++;
    }
    $output .= '</select>';
    return $self->wrap_field( $result, $output );
}

1;
