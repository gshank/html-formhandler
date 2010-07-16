package HTML::FormHandler::Field::PrimaryKey;
# ABSTRACT: primary key field

use Moose;
extends 'HTML::FormHandler::Field';

=head1 SYNOPSIS

   has_field 'addresses.address_id' => ( type => 'PrimaryKey' );

=cut

has 'is_primary_key' => ( isa => 'Bool', is => 'ro', default => '1' );
has '+widget' => ( default => 'hidden' );

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
