package HTML::FormHandler::Widget::Field::Role::SelectedOption;

use Moose::Role;
use namespace::autoclean;

sub check_selected_option {
    my ( $self, $fif, $option ) = @_;
    my $selected_key = $option->{'selected'} || $option->{'checked'};
    my $eq_values = $fif eq $option->{'value'};
    if ( defined $selected_key ) {
        return $selected_key && $eq_values;
    } else {
        return $eq_values;
    }
}

1;
