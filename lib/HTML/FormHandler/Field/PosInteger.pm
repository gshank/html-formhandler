package HTML::FormHandler::Field::PosInteger;
# ABSTRACT: positive integer field
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Integer';
our $VERSION = '0.02';

our $class_messages = {
    'integer_positive' => 'Value must be a positive integer',
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
            check   => sub { $_[0] >= 0 },
            message => sub {
                my ( $value, $field ) = @_;
                return $field->get_message('integer_positive');
            },
        }
    ]
);

=head1 DESCRIPTION

Tests that the input is an integer and has a positive value.

Customize error message 'integer_positive'.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
