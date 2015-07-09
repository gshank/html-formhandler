package HTML::FormHandler::Field::Hidden;
# ABSTRACT: hidden field
use strict;
use warnings;

use Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

has '+widget' => ( default => 'Hidden' );
has '+do_label' => ( default => 0 );
has '+html5_type_attr' => ( default => 'hidden' );

=head1 DESCRIPTION

This is a text field that uses the 'hidden' widget type, for HTML
of type 'hidden'.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
