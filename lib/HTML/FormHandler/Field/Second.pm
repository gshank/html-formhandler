package HTML::FormHandler::Field::Second;
# ABSTRACT: select list 0 to 59

use Moose;
extends 'HTML::FormHandler::Field::IntRange';
our $VERSION = '0.01';

has '+range_start' => ( default => 0 );
has '+range_end'   => ( default => 59 );

=head1 DESCRIPTION

A select field for seconds in the range of 0 to 59.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
