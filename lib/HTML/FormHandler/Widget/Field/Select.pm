package HTML::FormHandler::Widget::Field::Select;

use Moose::Role;

with 'HTML::FormHandler::Widget::Field::Role::SelectedOption';
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = '<select name="' . $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= ' multiple="multiple"' if $self->multiple == 1;
    $output .= ' size="' . $self->size . '"' if $self->size;
    $output .= $self->_add_html_attributes;
    $output .= '>';
    my $index = 0;
    if( $self->empty_select ) {
        $output .= '<option value="">' . $self->empty_select . '</option>'; 
    }
    foreach my $option ( @{ $self->{options} } ) {
        $output .= '<option value="' . $option->{value} . '" ';
        $output .= 'id="' . $self->id . ".$index\" ";
        if ( my $ffif = $self->html_filter($result->fif) ) {
            if ( $self->multiple == 1 ) {
                my @fif;
                if ( ref $ffif ) {
                    @fif = @{$ffif};
                }
                else {
                    @fif = ($ffif);
                }
                foreach my $optval (@fif) {
                    $output .= 'selected="selected"'
                        if $self->check_selected_option($option, $optval);
                }
            }
            else {
                $output .= 'selected="selected"'
                    if $self->check_selected_option($option, $ffif);
            }
        }
        $output .= 'selected="selected"'
            if $self->check_selected_option($option);
        $output .= '>' . $option->{label} . '</option>';
        $index++;
    }
    $output .= '</select>';
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
