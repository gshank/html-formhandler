package HTML::FormHandler::Field::Hour;
# ABSTRACT: accept integer from 0 to 23
use strict;
use warnings;

use Moose;
extends 'HTML::FormHandler::Field::IntRange';
our $VERSION = '0.03';

has '+range_start' => ( default => 0 );
has '+range_end'   => ( default => 23 );

=head1 DESCRIPTION

Enter an integer from 0 to 23 hours.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
