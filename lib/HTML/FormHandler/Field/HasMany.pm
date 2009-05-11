package HTML::FormHandler::Field::HasMany;

use Moose;
extends 'HTML::FormHandler::Field::Compound';
use aliased 'HTML::FormHandler::Field::HasMany::Instance';

=head1 NAME

HTML::FormHandler::Field::HasMany - Multiple row field

=head1 SYNOPSIS

  has_field 'addresses' => ( type => 'HasMany' );
  has_field 'addresses.street';
  has_field 'addresses.city';
  has_field 'addresses.state';

=head1 DESCRIPTION

=cut

has 'instances' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef',
   is         => 'rw',
   default    => sub { [] },
   auto_deref => 1,
   provides   => {
      clear => 'clear_instances',
      push  => 'add_instance',
      count => 'num_instances',
      empty => 'has_instances',
      set   => 'set_instance_at',
   }
);

has 'declared_fields' => (
   metaclass => 'Collection::Array',
   isa       => 'ArrayRef',
   is        => 'rw',
   default   => sub { [] },
   auto_deref => 1,
   provides   => {
     clear => 'clear_declared_fields',
     empty => 'has_declared_fields',
   },
);


sub clear_other
{
   my $self = shift;
   $self->clear_instances;
   $self->fields([$self->declared_fields]) if $self->has_declared_fields;
}


sub build_node 
{
   my $self = shift;

   my $input = $self->input;
   if ( ref $input eq 'ARRAY' )
   {
     # build appropriate instance array
      my $index = 0;
      foreach my $row ( @{$input} )
      {
         my $instance = $self->create_instance( $index );
         $instance->input($row);
         $index++;
      } 
      $self->declared_fields([$self->fields]);
      $self->fields([$self->instances]);
   }
   return unless $self->has_fields;
   $self->_fields_validate;
   my @value_array;
   for my $field ( $self->fields )
   { 
      push @value_array, $field->value;
   }
   $self->value( \@value_array );
};

sub _init_from_object
{
   my ($self, $values) = @_;

   # Create field instances and fill with values
   my $index = 0;
   my @new_values;
   foreach my $row ( @{$values} )
   {
      my $instance = $self->create_instance( $index );
      $self->form->_init_from_object($instance, $row);
      my $inst_value = $self->make_values([$instance->fields]);
      $instance->value($inst_value);
      push @new_values, $inst_value;
      $index++;
   } 
   $self->declared_fields([$self->fields]);
   $self->fields([$self->instances]);
   $self->value(\@new_values);
}

sub make_values
{
   my ( $self, $fields ) = @_;

   my $values;
   foreach my $field ( @{$fields} )
   {
      $values->{$field->accessor} = $field->value;
   }
   return $values;
}

sub create_instance
{
   my ( $self , $index ) = @_;
   my $instance = Instance->new( name => "$index", parent => $self ); 
   # copy the fields from this field into the instance
   $instance->add_field( $self->clone_fields );
   $instance->add_field( 
      HTML::FormHandler::Field->new(type => 'Hidden', name => 'id' ));
   $self->add_instance($instance);
   $_->parent($instance) for $instance->fields;
   return $instance;
}

sub clone_fields
{
   my $self = shift;
   my @field_array;

   foreach my $field ( $self->fields )
   {
      my $new_field = $field->clone;
      push @field_array, $new_field;
   }
   return @field_array;
}


1;
