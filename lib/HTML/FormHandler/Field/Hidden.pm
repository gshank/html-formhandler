package HTML::FormHandler::Field::Hidden;
# ABSTRACT: hidden field

use Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

has '+widget' => ( default => 'Hidden' );
has '+widget_wrapper' => ( default => 'None' );

=head1 DESCRIPTION

This is a text field that uses the 'hidden' widget type, for HTML
of type 'hidden'.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
