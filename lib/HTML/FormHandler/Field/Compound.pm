package HTML::FormHandler::Field::Compound;

use Moose;
use MooseX::AttributeHelpers;
extends 'HTML::FormHandler::Field';
with 'HTML::FormHandler::Fields';

=head1 NAME

HTML::FormHandler::Field::Compound - field consisting of subfields

=head1 SYNOPSIS

This field class is designed as the base (parent) class for fields with
multiple subfields. Examples are L<HTML::FormHandler::DateTime>
and L<HTML::FormHandler::Duration>.

A compound parent class requires the use of sub-fields prepended
with the parent class name plus a dot, and the 'parent' attribute
set to the name of the parent field:

   has_field 'birthdate' => ( type => 'DateTime' );
   has_field 'birthdate.year' => ( type => 'Year', parent => 'birthdate' );
   has_field 'birthdate.month' => ( type => 'Month', parent => 'birthdate' );
   has_field 'birthdate.day' => ( type => 'MonthDay', parent => 'birthdate' );

If all validation is performed in the parent class so that no
validation is necessary in the child classes, then the field class
'Nested' may be used.

Error messages will be applied to both parent classes and child
classes unless the 'errors_on_parent' flag is set. (This flag is
set for the 'Nested' field class.)

=head2 widget

Widget type is 'compound'

=cut

has '+widget' => ( default => 'compound' );

sub BUILD
{
   my $self = shift;
   $self->build_fields;
}

augment 'validate_field' => sub {
   my $self = shift;
   $self->clear_fif;
   return unless $self->has_fields;
   $self->fields_validate;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
