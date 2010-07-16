package HTML::FormHandler::Field::PosInteger;
# ABSTRACT: positive integer field

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Integer';
our $VERSION = '0.02';

apply(
    [
        {
            check   => sub { $_[0] >= 0 },
            message => 'Value must be a positive integer'
        }
    ]
);

=head1 DESCRIPTION

Tests that the input is an integer and has a postive value.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
