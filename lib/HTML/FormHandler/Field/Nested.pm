package HTML::FormHandler::Field::Nested;
# ABSTRACT: for nested elements of compound fields
use strict;
use warnings;

use Moose;
extends 'HTML::FormHandler::Field::Text';

=head1 SYNOPSIS

This field class is intended for nested elements of compound fields. It
does no particular validation, since the compound field should handle
that.

=cut



__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
