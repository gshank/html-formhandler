package HTML::FormHandler::Field::PrimaryKey;

use Moose;
extends 'HTML::FormHandler::Field';

=head1 NAME

HTML::FormHandler::Field::PrimaryKey - field for primary keys for
Repeatable related fields.

=head1 SYNOPSIS

   has_field 'addresses.address_id' => ( type => 'PrimaryKey' );

=cut

has 'is_primary_key' => ( isa => 'Bool', is => 'ro', default => '1' );
has '+widget' => ( default => 'hidden' );

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
