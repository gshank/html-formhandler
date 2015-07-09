package HTML::FormHandler::Field::DateMDY;
# ABSTRACT: m/d/y date field
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Date';

has '+format' => ( default => '%m/%d/%Y' );

=head1 SYNOPSIS

For date fields in the format nn/nn/nnnn. This simply inherits
from L<HTML::FormHandler::Field::Date> and sets the format
to "%m/%d/%Y".

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
