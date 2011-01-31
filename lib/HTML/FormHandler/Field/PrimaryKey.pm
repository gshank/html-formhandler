package HTML::FormHandler::Field::PrimaryKey;
# ABSTRACT: primary key field

use Moose;
extends 'HTML::FormHandler::Field';

=head1 SYNOPSIS

This field is for providing the primary key for Repeatable fields:

   has_field 'addresses' => ( type => 'Repeatable' );
   has_field 'addresses.address_id' => ( type => 'PrimaryKey' );

Do not use this field to hold the primary key of the form's main db object (item).
That primary key is in the 'item_id' attribute.

=cut

has 'is_primary_key' => ( isa => 'Bool', is => 'ro', default => '1' );
has '+widget' => ( default => 'hidden' );

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
