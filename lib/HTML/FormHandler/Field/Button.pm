package HTML::FormHandler::Field::Button;
# ABSTRACT: button field

use Moose;
extends 'HTML::FormHandler::Field::NoValue';

=head1 SYNOPSIS

Use this field to declare a button field in your form.

   has_field 'button' => ( type => 'Button', value => 'Press Me!' );

Uses the 'button' widget.

=cut

has '+widget' => ( default => 'Button' );

has '+value' => ( default => 'Button' );

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
