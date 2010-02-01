package HTML::FormHandler::Widget::Field::CheckboxGroup;

use Moose::Role;

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = " <br />";
    my $index  = 0;
    foreach my $option ( @{ $self->options } ) {
        $output .= '<input type="checkbox" value="' . $option->{value} . '"';
        $output .= ' name="' . $self->html_name . '" id="' . $self->id . ".$index\"";
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
                        if $optval == $option->{value};
                }
            }
            else {
                $output .= ' checked="checked"'
                    if $option->{value} eq $ffif;
            }
        }
        $output .= ' />';
        $output .= $option->{label} . '<br />';
        $index++;
    }
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
