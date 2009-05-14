package HTML::FormHandler::Field::Repeatable;

use Moose;
extends 'HTML::FormHandler::Field::Compound';
use aliased 'HTML::FormHandler::Field::Repeatable::Instance';

=head1 NAME

HTML::FormHandler::Field::Repeatable - Multiple row field

=head1 SYNOPSIS

  has_field 'addresses' => ( type => 'Repeatable' );
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

has 'num_when_empty' => ( isa => 'Int', is => 'rw', default => 1 );
has 'num_extra' => ( isa => 'Int', is => 'rw', default => 0 );
has 'index' => ( isa => 'Int', is => 'rw', default => 0 );

sub clear_other
{
   my $self = shift;
   # must clear out instances built last time
   $self->clear_instances;
   # move declared fields back into place so that Repeatable will
   # be called to build instances again
   $self->fields([$self->declared_fields]) if $self->has_declared_fields;
}


# this is called by Field->process when params exist and validation is done. 
# The input will already have # been set there, now percolate the input down 
# the tree and build instances
sub build_node 
{
   my $self = shift;

   my $input = $self->input;
   $self->clear_other;
   # if Repeatable has array input, need to build instances
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
      $self->index($index);
      $self->declared_fields([$self->fields]);
      $self->fields([$self->instances]);
   }
   return unless $self->has_fields;
   # call fields_validate to loop through array of fields created
   $self->_fields_validate;
   # now that values have been filled in via fields_validate,
   # create combined value for Repeatable
   my @value_array;
   for my $field ( $self->fields )
   { 
      push @value_array, $field->value;
   }
   $self->value( \@value_array );
};

# this is called when there is an init_object or an db item with values
sub _init_from_object
{
   my ($self, $values) = @_;

   $self->clear_other;
   # Create field instances and fill with values
   my $index = 0;
   my @new_values;
   foreach my $row ( @{$values} )
   {
      my $instance = $self->create_instance( $index );
      # load values from row into instance
      $self->form->_init_from_object($instance, $row);
      # create value for instance
      my $inst_value = $self->make_values([$instance->fields]);
      $instance->value($inst_value);
      # save values for Repeatable value
      push @new_values, $inst_value;
      $index++;
   } 
   $self->index($index);
   $self->declared_fields([$self->fields]);
   $self->fields([$self->instances]);
   $self->value(\@new_values);
}

# this is called when there are no params and no initial object
# because we need to build empty instances, and load select lists
sub _init
{
   my $self = shift;

   $self->clear_other;
   my $count = $self->num_when_empty;
   my $index = 0;
   # build empty instance
   while( $count > 0 )
   {
      my $instance = $self->create_instance( $index );
      $index++;
      $count--;
   } 
   $self->index($index);
   $self->declared_fields([$self->fields]);
   $self->fields([$self->instances]);
   # initialize the created instances
   $_->_init for $self->fields;
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
   unless( grep $_->can('is_primary_key') && $_->is_primary_key, @{$instance->fields})
   {
      $instance->add_field( 
         HTML::FormHandler::Field->new(type => 'Hidden', name => 'id' ));
   }
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
