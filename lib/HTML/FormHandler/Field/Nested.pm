package HTML::FormHandler::Field::Nested;

use Moose;
extends 'HTML::FormHandler::Field';

=head1 NAME

HTML::FormHandler::Field::Nested - for nested elements of compound fields

=head1 SYNOPSIS

This field class is intended for nested elements of compound fields. It
does no particular validation, since the compound field should handle
that.

=cut

has '+errors_on_parent' => ( default => 1 );

__PACKAGE__->meta->make_immutable;
no Moose;
1;
