package HTML::FormHandler::Widget::Field::Select;

use Moose::Role;
use HTML::Entities;

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = '<select name="' . $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= ' multiple="multiple"' if $self->multiple == 1;
    $output .= ' size="' . $self->size . '"' if $self->size;
    $output .= '>';
    my $index = 0;
    foreach my $option ( @{ $self->{options} } ) {
        $output .= '<option value="' . $option->{value} . '" ';
        $output .= 'id="' . $self->id . ".$index\" ";
        if ( my $ffif = encode_entities($result->fif) ) {
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
                        if $optval == $option->{value};
                }
            }
            else {
                $output .= 'selected="selected"'
                    if $option->{value} eq $ffif;
            }
        }
        $output .= '>' . $option->{label} . '</option>';
        $index++;
    }
    $output .= '</select>';
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
