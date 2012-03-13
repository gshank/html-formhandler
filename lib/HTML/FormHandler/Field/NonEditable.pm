package HTML::FormHandler::Field::NonEditable;
# ABSTRACT: reset field

use Moose;
extends 'HTML::FormHandler::Field::NoValue';

=head1 SYNOPSIS

Another flavor of a display field, but unlike L<HTML::FormHandler::Field::Display>
it's intended to be rendered somewhat more like a "real" field, like the
'non-editable' "fields" in Bootstrap.

   has_field 'source' => ( type => 'NonEditable', value => 'Outsourced' );

By default uses the 'Span' widget.

=cut

has '+widget' => ( default => 'Span' );

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
