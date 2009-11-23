package HTML::FormHandler::Field::Nested;

use Moose;
extends 'HTML::FormHandler::Field::Text';

=head1 NAME

HTML::FormHandler::Field::Nested - for nested elements of compound fields

=head1 SYNOPSIS

This field class is intended for nested elements of compound fields. It
does no particular validation, since the compound field should handle
that.

=cut



__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
