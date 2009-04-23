package HTML::FormHandler::Field::WeekdayStr;

use Moose;
extends 'HTML::FormHandler::Field::Weekday';
our $VERSION = '0.02';

__PACKAGE__->meta->make_immutable;

# Join the list of values into a single string

sub validate
{
   my $field = shift;
   my $input = $field->input;
   $field->value( join '', ref $input ? @{$input} : $input );
}

sub fif_value {
    my ( $field, $value) = @_;

    return unless $value;
    return ( $field->name, [ split //, $value ] );
}


=head1 NAME

HTML::FormHandler::Field::WeekdayStr

=head1 DESCRIPTION

This allow storage of multiple days of the week in a single string field.
as digits.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
