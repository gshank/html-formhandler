package HTML::FormHandler::Field::Repeatable;

use Moose;
extends 'HTML::FormHandler::Field::Compound';

use aliased 'HTML::FormHandler::Field::Repeatable::Instance';

=head1 NAME

HTML::FormHandler::Field::Repeatable - Repeatable (array) field

=head1 SYNOPSIS

In a form, for an array of hashrefs, equivalent to a 'has_many' database
relationship.

  has_field 'addresses' => ( type => 'Repeatable' );
  has_field 'addresses.address_id' => ( type => 'PrimaryKey' );
  has_field 'addresses.street';
  has_field 'addresses.city';
  has_field 'addresses.state';

For a database field include a PrimaryKey hidden field, or set 'auto_id' to
have an 'id' field automatically created.

In a form, for an array of single fields (not directly equivalent to a
database relationship) use the 'contains' pseudo field name:

  has_field 'tags' => ( type => 'Repeatable' );
  has_field 'tags.contains' => ( type => 'Text',
       apply => [ { check => ['perl', 'programming', 'linux', 'internet'],
                    message => 'Not a valid tag' } ]
  );

or use 'contains' withsingle fields which are compound fields:

  has_field 'addresses' => ( type => 'Repeatable' );
  has_field 'addresses.contains' => ( type => '+MyAddress' );

If the MyAddress field contains fields 'address_id', 'street', 'city', and
'state', then this syntax is functionally equivalent to the first method
where the fields are declared with dots ('addresses.city');

=head1 DESCRIPTION

This class represents an array. It can either be an array of hashrefs
(compound fields) or an array of single fields.

The 'contains' keyword is used for elements that do not have names
because they are not hash elements.

This field node will build arrays of fields from the the parameters or an
initial object, or empty fields for an empty form.

The name of the element fields will be an array index,
starting with 0. Therefore the first array element can be accessed with:

   $form->field('tags')->field('0')
   $form->field('addresses')->field('0)->field('city')

or using the shortcut form:

   $form->field('tags.0')
   $form->field('addresses.0.city')


=head1 ATTRIBUTES

=over

=item  index

This attribute contains the next index number available to create an
additional array element.

=item  num_when_empty

This attribute (default 1) indicates how many empty fields to present
in an empty form which hasn't been filled from parameters or database
rows.

=item auto_id

Will create an 'id' field automatically

=back

=cut

has 'contains' => ( isa => 'HTML::FormHandler::Field', is => 'rw',
     predicate => 'has_contains');

has 'num_when_empty' => ( isa => 'Int', is => 'rw', default => 1 );
has 'index' => ( isa => 'Int', is => 'rw', default => 0 );
has 'auto_id' => ( isa => 'Bool', is => 'rw', default => 0 );

sub clear_other
{
   my $self = shift;

   # must clear out instances built last time
   unless ( $self->has_contains )
   {
      if( $self->num_fields == 1 && $self->field('contains') )
      {
         $self->contains( $self->field('contains') );
      }
      else
      {
         $self->contains( $self->create_element );
      }
   }
   $self->clear_fields;
   $self->clear_value;
}

sub create_element
{
   my ( $self ) = @_;
   my $instance = Instance->new( name => 'contains', parent => $self,
      form => $self->form );
   # copy the fields from this field into the instance
   $instance->add_field( $self->fields );
   if( $self->auto_id )
   {
      unless( grep $_->can('is_primary_key') && $_->is_primary_key,
                                                  @{$instance->fields})
      {
         $instance->add_field(
            HTML::FormHandler::Field->new(type => 'PrimaryKey', name => 'id' ));
      }
   }
   $_->parent($instance) for $instance->fields;
   return $instance;
}

sub clone_element
{
   my ( $self, $index ) = @_;

   my $field = $self->contains->clone( errors => [], error_fields => [] );
   $field->name($index);
   $field->parent($self);
   if( $field->has_fields )
   {
      $self->clone_fields($field, [$field->fields]);
   }
   return $field;
}

sub clone_fields
{
   my ( $self, $parent, $fields ) = @_;
   my @field_array;
   foreach my $field ( @{$fields} )
   {
      my $new_field = $field->clone( errors => [], error_fields => [] );
      if( $new_field->has_fields )
      {
         $self->clone_fields( $new_field, [$new_field->fields] );
      }
      $new_field->parent($parent);
      push @field_array, $new_field;
   }
   $parent->fields(\@field_array);
}


# this is called by Field->process when params exist and validation is done.
# The input will already have # been set there, now percolate the input down
# the tree and build instances
sub process_node
{
   my $self = shift;

   my $input = $self->input;
   $self->clear_other;
   # if Repeatable has array input, need to build instances
   my @fields;
   if ( ref $input eq 'ARRAY' )
   {
     # build appropriate instance array
      my $index = 0;
      foreach my $element ( @{$input} )
      {
         next unless $element;
         my $field = $self->clone_element($index);
         $field->input($element);
         push @fields, $field;
         $index++;
      }
      $self->index($index);
      $self->fields(\@fields);
   }
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
   my @fields;
   my @new_values;
   $values = [$values] if ( $values && ref $values ne 'ARRAY');
   foreach my $element ( @{$values} )
   {
      next unless $element;
      my $field = $self->clone_element($index);
      if( $field->has_fields )
      {
         $self->form->_init_from_object($field, $element);
         my $ele_value = $self->make_values([$field->fields]);
         $field->value($ele_value);
         push @new_values, $ele_value;
      }
      else
      {
         $field->value($element);
      }
      push @fields, $field;
      $index++;
   }
   $self->index($index);
   $self->fields(\@fields);
   $self->value(\@new_values) if scalar @new_values;
   $self->value($values) unless scalar @new_values;
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

# this is called when there are no params and no initial object
# because we need to build empty instances, and load select lists
sub _init
{
   my $self = shift;

   $self->clear_other;
   my $count = $self->num_when_empty;
   my $index = 0;
   # build empty instance
   my @fields;
   while( $count > 0 )
   {
      my $field = $self->clone_element($index);
      push @fields, $field;
      $index++;
      $count--;
   }
   $self->index($index);
   $self->fields(\@fields);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
