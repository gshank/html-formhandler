package HTML::FormHandler::Widget::Field::Role::SelectedOption;

use Moose::Role;
use namespace::autoclean;

sub check_selected_option {
    my ( $self, $fif, $option ) = @_;
    my $selected_key = defined($option->{'selected'}) ?
        $option->{'selected'}
        : $option->{'checked'};
    if ( defined $selected_key ) {
        return $selected_key;
    } else {
        return $fif eq $option->{'value'};
    }
}

1;
