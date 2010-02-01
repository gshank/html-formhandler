package HTML::FormHandler::Field::Reset;

use Moose;
extends 'HTML::FormHandler::Field::NoValue';

=head1 NAME

HTML::FormHandler::Field::Reset - reset field

=head1 SYNOPSIS

Use this field to declare a reset field in your form.

   has_field 'reset' => ( type => 'Reset', value => 'Restore' );

Uses the 'reset' widget.

=cut

has '+widget' => ( default => 'reset' );

has '+value' => ( default => 'Reset' );

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
