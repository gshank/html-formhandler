package HTML::FormHandler::Field::Weekday;
# ABSTRACT: select list day of week strings

use Moose;
extends 'HTML::FormHandler::Field::Select';
our $VERSION = '0.01';

sub build_options {
    my $i    = 0;
    my @days = qw/
        Sunday
        Monday
        Tuesday
        Wednesday
        Thursday
        Friday
        Saturday
        /;
    return [ map { { value => $i++, label => $_ } } @days ];
}

=head1 DESCRIPTION

Creates an option list for the days of the week.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
