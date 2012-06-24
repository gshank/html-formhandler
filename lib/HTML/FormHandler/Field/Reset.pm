package HTML::FormHandler::Field::Reset;
# ABSTRACT: reset field

use Moose;
extends 'HTML::FormHandler::Field::NoValue';

=head1 SYNOPSIS

Use this field to declare a reset field in your form.

   has_field 'reset' => ( type => 'Reset', value => 'Restore' );

Uses the 'reset' widget.

=cut

has '+widget' => ( default => 'Reset' );
has '+value' => ( default => 'Reset' );
has '+type_attr' => ( default => 'reset' );
has '+html5_type_attr' => ( default => 'reset' );
sub do_label {0}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
