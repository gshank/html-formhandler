package HTML::FormHandler::Field::Email;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
use Email::Valid;
our $VERSION = '0.02';

apply(
    [
        {
            transform => sub { lc( $_[0] ) }
        },
        {
            check => sub { Email::Valid->address( $_[0] ) },
            message => [ 'Email should be of the format [_1]', 'someuser@example.com' ]
        }
    ]
);

=head1 NAME

HTML::FormHandler::Field::Email - Validates email uisng Email::Valid

=head1 DESCRIPTION

Validates that the input looks like an email address uisng L<Email::Valid>.
Widget type is 'text'.

=head1 DEPENDENCIES

L<Email::Valid>

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
