package HTML::FormHandler::Field::Money;
# ABSTRACT: US currency-like values
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

has '+html5_type_attr' => ( default => 'number' );

our $class_messages = {
    'money_convert' => 'Value cannot be converted to money',
    'money_real'    => 'Value must be a real number',
};

sub get_class_messages  {
    my $self = shift;
    return {
        %{ $self->next::method },
        %$class_messages,
    }
}

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
            message => sub {
                my ( $value, $field ) = @_;
                return [$field->get_message('money_convert'), $value];
            },
        },
        {
            check => sub { $_[0] =~ /^-?\d+\.?\d*$/ },
            message => sub {
                my ( $value, $field ) = @_;
                return [$field->get_message('money_real'), $value];
            },
        }
    ]
);

=head1 DESCRIPTION

Validates that a positive or negative real value is entered.
Formatted with two decimal places.

Uses a period for the decimal point. Widget type is 'text'.

If form has 'is_html5' flag active it will render <input type="number" ... />
instead of type="text"

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
