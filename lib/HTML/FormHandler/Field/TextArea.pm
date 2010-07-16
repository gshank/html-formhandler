package HTML::FormHandler::Field::TextArea;
# ABSTRACT: textarea input

use Moose;
extends 'HTML::FormHandler::Field';
our $VERSION = '0.01';

has '+widget' => ( default => 'textarea' );
has 'cols'    => ( isa     => 'Int', is => 'rw' );
has 'rows'    => ( isa     => 'Int', is => 'rw' );

=head1 Summary

For HTML textarea. Uses 'textarea' widget. Set cols/row.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
