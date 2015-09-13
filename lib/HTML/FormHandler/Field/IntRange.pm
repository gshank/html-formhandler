package HTML::FormHandler::Field::IntRange;
# ABSTRACT: integer range in select list
use strict;
use warnings;

use Moose;
extends 'HTML::FormHandler::Field::Select';
our $VERSION = '0.01';

has 'label_format' => ( isa => 'Str', is => 'rw', default => '%d' );
has '+range_start' => ( default => 1 );
has '+range_end'   => ( default => 10 );

sub build_options {
    my $self = shift;

    my $start = $self->range_start;
    my $end   = $self->range_end;

    for ( $start, $end ) {
        die "Both range_start and range_end must be defined" unless defined $_;
        die "Integer ranges must be integers" unless /^\d+$/;
    }

    die "range_start must be less than range_end" unless $start < $end;

    my $format = $self->label_format || die 'IntRange needs label_format';

    return [ map { { value => $_, label => sprintf( $format, $_ ) } }
            $self->range_start .. $self->range_end ];
}

=head1 DESCRIPTION

This field generates a select list of numbers from 1 to 10. Override the
range_start and range_end for a select list with a different range.

   has_field 'age' => ( type => 'IntRange',
               range_start => 0, range_end => 100 );

Widget type is 'select'.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
