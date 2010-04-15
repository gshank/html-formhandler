package HTML::FormHandler::Widget::Field::CheckboxGroup;

use Moose::Role;

with 'HTML::FormHandler::Widget::Field::Role::SelectedOption';
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

has 'input_without_param' => ( is => 'ro', default => sub {[]} );
has 'not_nullable' => ( is => 'ro', default => 1 );

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
                        if $self->check_selected_option($option, $optval);
                }
            }
            else {
                $output .= ' checked="checked"'
                    if $self->check_selected_option($option, $ffif);
            }
        }
        $output .= ' checked="checked"'
            if $self->check_selected_option($option);
        $output .= $self->_add_html_attributes;
        $output .= ' />';
        $output .= $option->{label} . '<br />';
        $index++;
    }
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
