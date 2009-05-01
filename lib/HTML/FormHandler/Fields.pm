package HTML::FormHandler::Fields;

use Moose::Role;
use Carp;
use UNIVERSAL::require;
use Class::Inspector;

=head1 NAME

HTML::FormHandler::Fields - role to build field array

=head1 SYNOPSIS

These are internal methods to build the field array. Probably
not useful to users. 

=head2 fields

The field definitions as built from the field_list and the 'has_field'
declarations. This is a MooseX::AttributeHelpers::Collection::Array, 
and provides clear_fields, add_field, remove_last_field, num_fields,
has_fields, and set_field_at methods.

=cut

has 'fields' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[HTML::FormHandler::Field]',
   is         => 'rw',
   default    => sub { [] },
   auto_deref => 1,
   provides   => {
      clear => 'clear_fields',
      push  => 'add_field',
      pop   => 'remove_last_field',
      count => 'num_fields',
      empty => 'has_fields',
      set   => 'set_field_at',
   }
);

=head2 build_fields

This parses the field lists and creates the individual
field objects.  It calls the _make_field() method for each field.
This is called by the BUILD method. Users don't need to call this.

=cut

sub build_fields
{
   my $self = shift;

   my $meta_flist = $self->_build_meta_field_list;
   $self->_process_field_array( $meta_flist, 0 ) if $meta_flist;
   $self->_process_field_list( $self->field_list )
      if ( $self->can('field_list') && $self->has_field_list );
   return unless $self->has_fields;

   # get highest order number
   my $order = 0;
   foreach my $field ( $self->fields )
   {
      $order++ if $field->order > $order;
   }
   $order++;
   # number all unordered fields
   my @expand_fields;
   foreach my $field ( $self->fields )
   {
      $field->order($order) unless $field->order;
      $order++;
      # collect child references in parent field
      push @expand_fields, $field if $field->name =~ /\./;
   }
   @expand_fields = sort { $a->name cmp $b->name } @expand_fields;
   foreach my $field (@expand_fields)
   {
      my @names       = split /\./, $field->name;
      my $simple_name = pop @names;
      my $parent_name = pop @names;
      my $parent      = $self->field($parent_name);
      next unless $parent;
      $field->parent($parent);
      $field->name($simple_name);
      $parent->add_field($field);
   }

}

sub _process_field_list
{
   my ( $self, $flist ) = @_;

   $self->_process_field_array( $self->_hashref_fields( $flist->{'required'}, 1 ) )
      if $flist->{'required'};
   $self->_process_field_array( $self->_hashref_fields( $flist->{'optional'}, 0 ) )
      if $flist->{'optional'};
   $self->_process_field_array( $self->_hashref_fields( $flist->{'fields'} ) )
      if ( $flist->{'fields'} && ref $flist->{'fields'} eq 'HASH' );
   $self->_process_field_array( $self->_array_fields( $flist->{'fields'} ) )
      if ( $flist->{'fields'} && ref $flist->{'fields'} eq 'ARRAY' );
   $self->_process_field_array( $self->_auto_fields( $flist->{'auto_required'}, 1 ) )
      if $flist->{'auto_required'};
   $self->_process_field_array( $self->_auto_fields( $flist->{'auto_optional'}, 0 ) )
      if $flist->{'auto_optional'};
}

sub _build_meta_field_list
{
   my $self = shift;
   my @field_list;
   foreach my $sc ( reverse $self->meta->linearized_isa )
   {
      my $meta = $sc->meta;
      if ( $meta->can('calculate_all_roles') )
      {
         foreach my $role ( $meta->calculate_all_roles )
         {
            if ( $role->can('field_list') && $role->has_field_list )
            {
               push @field_list, @{ $role->field_list };
            }
         }
      }
      if ( $meta->can('field_list') && $meta->has_field_list )
      {
         push @field_list, @{ $meta->field_list };
      }
   }
   return \@field_list if scalar @field_list;
}

# munges the field_list auto fields into an array of field attributes
sub _auto_fields
{
   my ( $self, $fields, $required ) = @_;

   my @new_fields;
   foreach my $name (@$fields)
   {
      push @new_fields,
         {
         name     => $name,
         type     => $self->guess_field_type($name),
         required => $required
         };
   }
   return \@new_fields;
}

# munges the field_list hashref fields into an array of field attributes
sub _hashref_fields
{
   my ( $self, $fields, $required ) = @_;
   my @new_fields;
   while ( my ( $key, $value ) = each %{$fields} )
   {
      unless ( ref $value eq 'HASH' )
      {
         $value = { type => $value };
      }
      if ( defined $required )
      {
         $value->{required} = $required;
      }
      push @new_fields, { name => $key, %$value };
   }
   return \@new_fields;
}

# munges the field_list array into an array of field attributes
sub _array_fields
{
   my ( $self, $fields ) = @_;

   my @new_fields;
   while (@$fields)
   {
      my $name = shift @$fields;
      my $attr = shift @$fields;
      unless ( ref $attr eq 'HASH' )
      {
         $attr = { type => $attr };
      }
      push @new_fields, { name => $name, %$attr };
   }
   return \@new_fields;
}

sub _process_field_array
{
   my ( $self, $fields ) = @_;

   my $num_fields   = scalar @$fields;
   my $num_dots     = 0;
   my $count_fields = 0;
   while ( $count_fields < $num_fields )
   {
      foreach my $field (@$fields)
      {
         my $count = ( $field->{name} =~ tr/\.// );
         next unless $count == $num_dots;
         $self->_set_field($field);
         $count_fields++;
      }
      $num_dots++;
   }

}

# this looks for existing fields by $name or full_name
# some fields don't have their names adjusted until later
# (duration.month) in build_fields so some fields might not be found.
# But parent field might not exist yet, so can't do here.
# catch 22?
sub _set_field
{
   my ( $self, $field_attr ) = @_;

   if ( $field_attr->{name} =~ /^\+(.*)/ )
   {
      my $name           = $1;
      my $existing_field = $self->field($name);
      if ($existing_field)
      {
         delete $field_attr->{name};
         foreach my $key ( keys %{$field_attr} )
         {
            $existing_field->$key( $field_attr->{$key} )
               if $existing_field->can($key);
         }
      }
      else
      {
         warn "HFH: field $name does not exist. Cannot update.";
      }
      return;
   }
   $self->_make_field($field_attr);
}

=head2 _make_field

    $field = $form->_make_field( $field_attr );

Maps the field type to a field class, creates a field object and
and returns it.

The 'field_attr' hashref must have a 'name' key


=cut

sub _make_field
{
   my ( $self, $field_attr ) = @_;

   $field_attr->{type} ||= 'Text';
   my $type = $field_attr->{type};
   my $name = $field_attr->{name};
   return unless $name;

   # TODO what about fields with fields? namespace from where?
   my $class =
        $type =~ s/^\+//
      ? $self->field_name_space
         ? $self->field_name_space . "::" . $type
         : $type
      : 'HTML::FormHandler::Field::' . $type;

   $class->require
      or die "Could not load field class '$type' $class for field '$name'"
      if !Class::Inspector->loaded($class);

   $field_attr->{form} = $self->form if $self->form;
   # parent and name correction
   if ( $field_attr->{name} =~ /\./ )
   {
      my @names       = split /\./, $field_attr->{name};
      my $simple_name = pop @names;
      my $parent_name = join '.', @names;
      my $parent      = $self->field($parent_name);
      if ($parent)
      {
         die "The parent of field " . $field_attr->{name} . " is not a Compound Field"
            unless $parent->isa('HTML::FormHandler::Field::Compound'); 
         $field_attr->{parent} = $parent;
         $field_attr->{name}   = $simple_name;
      }
   }
   elsif ( !($self->form && $self == $self->form ) )
   {
      # set parent 
      $field_attr->{parent} = $self;
   }
   my $field = $class->new( %{$field_attr} );
   $self->update_or_create( $field->parent || $self->form, $field );
}

sub update_or_create
{
   my ( $self, $parent, $field ) = @_; 

   my $index = $parent->field_index( $field->name );
   if ( defined $index ) 
   { $parent->set_field_at( $index, $field ); }
   else                  
   { $parent->add_field($field); }
}

=head2 field_index

Convenience function for use with 'set_field_at'. Pass in 'name' of field
(not full_name)

=cut 

sub field_index
{
   my ( $self, $name ) = @_;
   my $index = 0;
   for my $field ( $self->fields )
   {
      return $index if $field->name eq $name;
      $index++;
   }
   return;
}

=head2 field

=cut

sub field
{
   my ( $self, $name, $die ) = @_;

   my $index;
   if( $name =~ /\./ )
   {
      my @names = split /\./, $name;
      my $f = $self->form;
      foreach my $fname (@names)
      {
         $f = $f->field($fname); 
      }
      return $f;
   }
   else
   {
      for my $field ( $self->fields )
      {
         return $field if ( $field->name eq $name );
      }
   }
   return unless $die;
   croak "Field '$name' not found in '$self'";
}

=head2 sorted_fields

Calls fields and returns them in sorted order by their "order"
value. Non-sorted fields are retrieved with 'fields'. 

=cut

sub sorted_fields
{
   my $self = shift;

   my @fields = sort { $a->order <=> $b->order } $self->fields;
   return wantarray ? @fields : \@fields;
}

=head2 fields_validate

=cut

sub fields_validate
{
   my $self = shift;
   # validate all fields
   foreach my $field ( $self->fields )
   {
      next if $field->clear;    # Skip validation
                                # parent fields will call validation for children
      next if $field->parent && $field->parent != $self;
      # Validate each field and "inflate" input -> value.
      $field->process;          # this calls the field's 'validate' routine
      next unless $field->has_value && defined $field->value;
      # these methods have access to the inflated values
      $field->_validate($field);    # will execute a form-field validation routine
   }
}

=head2 clear_errors

Clears field errors

=cut

sub clear_errors
{
   my $self = shift;
   $_->clear_errors for $self->fields;
}

=head2 clear_fif

Clears fif values

=cut

sub clear_fifs
{
   my $self = shift;

   foreach my $field ($self->fields)
   {
      $field->clear_fifs if $field->can('clear_fifs');
      $field->clear_fif;
   }
}

=head2 clear_values

Clears fif values

=cut

sub clear_values
{
   my $self = shift;
   foreach my $field ($self->fields)
   {
      $field->clear_values if $field->can('clear_values');
      $field->clear_value;
   }
}

=head2 dump

Dumps the the array of fields for debugging. This method is called when
the verbose flag is turned on.

=cut

sub dump_fields { shift->dump( @_) }
sub dump
{
   my $self = shift;

   warn "HFH: ------- fields for ", $self->name, "-------\n";
   for my $field ( $self->sorted_fields )
   {
      $field->dump;
   }
   warn "HFH: ------- end fields -------\n";
}

=head2 dump_validated

For debugging, dump the validated fields. This method is called when the
verbose flag is on.

=cut

sub dump_validated
{
   my $self = shift;
   warn "HFH: fields validated:\n";
   foreach my $field ( $self->fields )
   {
      $field->dump_validated if $field->can('dump_validated');
      warn "HFH: ", $field->name, ": ", 
      ( $field->has_errors ? join( ' | ', $field->errors ) : 'validated' ), "\n";
   } 
}

no Moose::Role;
1;
