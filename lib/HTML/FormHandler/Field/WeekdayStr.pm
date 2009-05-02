package HTML::FormHandler::Field::WeekdayStr;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Weekday';
our $VERSION = '0.03';

__PACKAGE__->meta->make_immutable;

# Join the list of values into a single string

apply ([
   { transform => sub { join '', ref $_[0] ? @{$_[0]} : $_[0] } }
]);

sub fif_value {
    my ( $field, $value) = @_;

    return unless $value;
    return ( $field->name, [ split //, $value ] );
}


=head1 NAME

HTML::FormHandler::Field::WeekdayStr

=head1 DESCRIPTION

This allow storage of multiple days of the week in a single string field.
as digits. The value of 'Monday Wednesday Friday' would be '135', for
example.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no HTML::FormHandler::Moose;
1;
