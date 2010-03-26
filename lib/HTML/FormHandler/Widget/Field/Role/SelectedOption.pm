package HTML::FormHandler::Widget::Field::Role::SelectedOption;

use Moose::Role;
use namespace::autoclean;

sub check_selected_option {
    my ( $self, $option, $fif ) = @_;
    my $selected_key = defined($option->{'selected'}) ?
        $option->{'selected'}
        : $option->{'checked'};
    if ( defined $selected_key ) {
        return $selected_key;
    } elsif ( defined $fif ) {
        return $fif eq $option->{'value'};
    } else {
        return;
    }
}

1;
