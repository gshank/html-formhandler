package HTML::FormHandler::Field::PosInteger;

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

=head1 NAME

HTML::FormHandler::Field::PosInteger - Validates input is a positive integer

=head1 DESCRIPTION

Tests that the input is an integer and has a postive value.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
