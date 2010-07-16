package HTML::FormHandler::Field::Money;
# ABSTRACT: US currency-like values

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

apply(
    [
        {
            transform => sub {
                my $value = shift;
                $value =~ s/^\$//;
                return $value;
                }
        },
        {
            transform => sub { sprintf '%.2f', $_[0] },
            message   => 'Value cannot be converted to money'
        },
        {
            check => sub { $_[0] =~ /^-?\d+\.?\d*$/ },
            message => 'Value must be a real number'
        }
    ]
);

=head1 DESCRIPTION

Validates that a postive or negative real value is entered.
Formatted with two decimal places.

Uses a period for the decimal point. Widget type is 'text'.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
