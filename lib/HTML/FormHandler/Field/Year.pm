package HTML::FormHandler::Field::Year;

use Moose;
extends 'HTML::FormHandler::Field::IntRange';

our $VERSION = '0.01';

has '+range_start' => (
    default => sub {
        my $year = (localtime)[5] + 1900 - 5;
        return $year;
    }
);
has '+range_end' => (
    default => sub {
        my $year = (localtime)[5] + 1900 + 10;
        return $year;
    }
);

=head1 NAME

HTML::FormHandler::Field::Year - Select a recent year.

=head1 DESCRIPTION

Provides a list of years starting five years back and extending 10 years into
the future.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
