package HTML::FormHandler::Widget::Field::CheckboxGroup;
# ABSTRACT: checkbox group field role

use Moose::Role;
use namespace::autoclean;

with 'HTML::FormHandler::Widget::Field::Role::SelectedOption';
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $output = " <br />";
    my $index  = 0;
    my $id = $self->id;
    my $html_attributes = $self->_add_html_attributes;

    foreach my $option ( @{ $self->options } ) {
        $output .= '<input type="checkbox" value="'
            . $self->html_filter($option->{value}) . '" name="'
            . $self->html_name . qq{" id="$id.$index"};
        if ( my $ffif = $result->fif ) {
            if ( $self->multiple == 1 ) {
                my @fif;
                if ( ref $ffif ) {
                    @fif = @{$ffif};
                }
                else {
                    @fif = ($ffif);
                }
                foreach my $optval (@fif) {
                    $output .= ' checked="checked"'
                        if $self->check_selected_option($option, $optval);
                }
            }
            else {
                $output .= ' checked="checked"'
                    if $self->check_selected_option($option, $ffif);
            }
        }
        $output .= $html_attributes;
        $output .= ' />';
        $output .= $self->html_filter($option->{label}) . '<br />';
        $index++;
    }
    return $self->wrap_field( $result, $output );
}

1;
