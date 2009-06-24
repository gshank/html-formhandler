package HTML::FormHandler::Fields;

use Moose::Role;
use Carp;

=head1 NAME

HTML::FormHandler::Fields - role to build field array

=head1 SYNOPSIS

These are the methods that are necessary to build and access the
fields arrays in a form and a compound field. This is a role which
is composed into L<HTML::FormHandler> and 
L<HTML::FormHandler::Field::Compound>

=head2 fields

The field definitions as built from the field_list and the 'has_field'
declarations. This is a MooseX::AttributeHelpers::Collection::Array, 
and provides clear_fields, add_field, remove_last_field, num_fields,
has_fields, and set_field_at methods.

=head2 field( $full_name )

Return the field objct with the full_name passed. Will return undef
if the field is not found, or will die if passed a second parameter.

=head2 field_index

Convenience function for use with 'set_field_at'. Pass in 'name' of field
(not full_name)

=head2 sorted_fields

Calls fields and returns them in sorted order by their "order"
value. Non-sorted fields are retrieved with 'fields'. 

=head2 clear methods

  clear_errors
  clear_fifs
  clear_values

=head2 Dump information 

   dump - turn verbose flag on to get this output
   dump_validated - shorter version

=cut


has 'fields' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[HTML::FormHandler::Field]',
   is         => 'rw',
   default    => sub { [] },
   auto_deref => 1,
   provides   => {
      clear => 'clear_fields',
      push  => 'push_field',
      pop   => 'remove_last_field',
      count => 'num_fields',
      empty => 'has_fields',
      set   => 'set_field_at',
   }
);
has 'error_fields' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[HTML::FormHandler::Field]',
   is         => 'rw',
   default    => sub { [] },
   auto_deref => 1,
   provides   => {
      empty => 'has_error_fields',
      clear => 'clear_error_fields',
      push  => 'add_error_field',
      count => 'num_error_fields'
   }
);


has 'fields_from_model' => ( isa => 'Bool', is => 'rw' );

sub add_field
{
   shift->push_field(@_);
}

has 'field_name_space' => (
   isa     => 'Str|Undef',
   is      => 'rw',
   lazy    => 1,
   default => '',
);

has 'field_list' => ( isa => 'HashRef|ArrayRef', is => 'rw', default => sub { {} } );
sub has_field_list
{
   my ( $self, $field_list ) = @_;
   $field_list ||= $self->field_list;
   if( ref $field_list eq 'HASH' )
   {
      return $field_list if( scalar keys %{$field_list} );
   }
   elsif( ref $field_list eq 'ARRAY' )
   {
      return $field_list if( scalar @{$field_list} );
   }
   return;
}

# _init is for building select lists and empty repeatables when
# there is no initial object and no params
sub _init
{
   $_->_init for shift->fields;
}

# calls routines to process various field lists
# orders the fields after processing in order to skip
# fields which have had the 'order' attribute set 
sub _build_fields
{
   my $self = shift;

   my $meta_flist = $self->_build_meta_field_list;
   $self->_process_field_array( $meta_flist, 0 ) if $meta_flist;
   my $flist = $self->has_field_list;
   $self->_process_field_list( $flist ) if $flist;
   return unless $self->has_fields;

   # order the fields
   # There's a hole in this... if child fields are defined at
   # a level above the containing parent, then they won't
   # exist when this routine is called and won't be ordered.
   # This probably needs to be moved out of here into
   # a separate recursive step that's called after build_fields.

   # get highest order number
   my $order = 0;
   foreach my $field ( $self->fields )
   {
      $order++ if $field->order > $order;
   }
   $order++;
   # number all unordered fields
   foreach my $field ( $self->fields )
   {
      $field->order($order) unless $field->order;
      $order++;
   }
}


# process all the stupidly many different formats for field_list
# remove undocumented syntaxes after a while
sub _process_field_list
{
   my ( $self, $flist ) = @_;

   if ( ref $flist eq 'ARRAY' )
   {
      $self->_process_field_array( $self->_array_fields( $flist ) );
      return;
   };
   # these should go away. not really necessary
   $self->_process_field_array( $self->_hashref_fields( $flist->{'required'}, 1 ) )
      if $flist->{'required'};
   $self->_process_field_array( $self->_hashref_fields( $flist->{'optional'}, 0 ) )
      if $flist->{'optional'};
   # these next two are deprecated. use array instead
   if ( $flist->{'fields'} )
   {
      warn 'Using the \'fields\' key in field_list is deprecated. Please switch to using field_list => [ <fields> ] instead'; 
      $self->_process_field_array( $self->_hashref_fields( $flist->{'fields'} ) )
         if( ref $flist->{'fields'} eq 'HASH' );
      $self->_process_field_array( $self->_array_fields( $flist->{'fields'} ) )
         if ( ref $flist->{'fields'} eq 'ARRAY' );
   }
   # don't encourage use of these two. functionality too limited. 
   $self->_process_field_array( $self->model_fields ) if $self->fields_from_model;
   $self->_process_field_array( $self->_auto_fields( $flist->{'auto_required'}, 1 ) )
      if $flist->{'auto_required'};
   $self->_process_field_array( $self->_auto_fields( $flist->{'auto_optional'}, 0 ) )
      if $flist->{'auto_optional'};
}

# loops through all inherited classes and composed roles
# to find fields specified with 'has_field'
sub _build_meta_field_list
{
   my $self = shift;
   my @field_list;

   foreach my $sc ( reverse $self->meta->linearized_isa )
   {
      my $meta = $sc->meta;
      if ( $meta->can('calculate_all_roles') )
      {
         foreach my $role ( reverse $meta->calculate_all_roles )
         {
            if ( $role->can('field_list') && $role->has_field_list )
            {
               foreach my $fld_def ( @{ $role->field_list} )
               {
                  my %new_fld = %{$fld_def}; # copy hashref
                  push @field_list, \%new_fld; 
               }
            }
         }
      }
      if ( $meta->can('field_list') && $meta->has_field_list )
      {
         foreach my $fld_def ( @{$meta->field_list} )
         {
            my %new_fld = %{$fld_def}; # copy hashref
            push @field_list, \%new_fld; 
         }
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

# loop through array of field hashrefs
sub _process_field_array
{
   my ( $self, $fields ) = @_;

   # the point here is to process fields in the order parents
   # before children, so we process all fields with no dots
   # first, then one dot, then two dots...
   my $num_fields   = scalar @$fields;
   my $num_dots     = 0;
   my $count_fields = 0;
   while ( $count_fields < $num_fields )
   {
      foreach my $field (@$fields)
      {
         my $count = ( $field->{name} =~ tr/\.// );
         next unless $count == $num_dots;
         $self->_make_field($field);
         $count_fields++;
      }
      $num_dots++;
   }

}

# Maps the field type to a field class, finds the parent,
# sets the 'form' attribute, calls update_or_create
# The 'field_attr' hashref must have a 'name' key
sub _make_field
{
   my ( $self, $field_attr ) = @_;

   $field_attr->{type} ||= 'Text';
   my $type = $field_attr->{type};
   my $name = $field_attr->{name};
   return unless $name;

   my $do_update;
   if( $name =~ /^\+(.*)/ )
   {
      $field_attr->{name} = $name = $1;
      $do_update = 1;
   }

   my $class =
        $type =~ s/^\+//
      ? $self->field_name_space
         ? $self->field_name_space . "::" . $type
         : $type
      : 'HTML::FormHandler::Field::' . $type;

    Class::MOP::load_class($class)
      or die "Could not load field class '$type' $class for field '$name'";

   $field_attr->{form} = $self->form if $self->form;
   # parent and name correction for names with dots
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
   $self->_update_or_create( $field_attr->{parent} || $self->form, 
                          $field_attr, $class, $do_update );
}


# update, replace, or create field
sub _update_or_create
{
   my ( $self, $parent, $field_attr, $class, $do_update ) = @_; 

   my $index = $parent->field_index( $field_attr->{name} );
   my $field;
   if ( defined $index ) 
   { 
      if( $do_update ) # this field started with '+'. Update.
      {
         $field = $parent->field($field_attr->{name}); 
         die "Field to update for " . $field_attr->{name} . " not found"
            unless $field;
         delete $field_attr->{name};
         foreach my $key ( keys %{$field_attr} )
         {
            $field->$key( $field_attr->{$key} )
               if $field->can($key);
         }
      }
      else # replace existing field
      {
         $field = $class->new( %{$field_attr} );
         $parent->set_field_at( $index, $field ); 
      }
   }
   else # new field
   {  
      $field = $class->new( %{$field_attr} );
      $parent->add_field($field); 
   }
}

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

sub field
{
   my ( $self, $name, $die ) = @_;

   my $index;
   # if this is a full_name for a compound field
   # walk through the fields to get to it
   if( $name =~ /\./ )
   {
      my @names = split /\./, $name;
      my $f = $self->form || $self;
      foreach my $fname (@names)
      {
         $f = $f->field($fname); 
         return unless $f;
      }
      return $f;
   }
   else # not a compound name
   {
      for my $field ( $self->fields )
      {
         return $field if ( $field->name eq $name );
      }
   }
   return unless $die;
   croak "Field '$name' not found in '$self'";
}

# this may be an array of fields flattened from the tree
sub sorted_fields
{
   my $self = shift;

   my @fields = sort { $a->order <=> $b->order } $self->fields;
   return wantarray ? @fields : \@fields;
}

#  the routine for looping through and processing each field
#  Called in build_node
sub _fields_validate
{
   my $self = shift;
   # validate all fields
   foreach my $field ( $self->fields )
   {
      next if $field->clear;    # Skip validation
      # Validate each field and "inflate" input -> value.
      $field->validate_field;   # this calls the field's 'validate' routine
   }
   $self->cross_validate;
}

sub cross_validate { }

after clear_data => sub
{
   my $self = shift;
   $self->clear_error_fields;
   $_->clear_data for $self->fields;
};

sub get_error_fields
{
   my $self = shift;
   my @error_fields;
   foreach my $field ($self->sorted_fields)
   {
      if( $field->has_fields )
      {
         $field->get_error_fields;
         push @error_fields, $field->error_fields if $field->has_error_fields;
      }
      push @error_fields, $field if $field->has_errors;
   }
   $self->add_error_field(@error_fields) if scalar @error_fields;
}

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

sub build_node
{  
   my $self = shift;

   return unless $self->has_fields;
   my $input = $self->input;
   # transfer the input values to the input attributes of the
   # subfields 
   if( ref $input eq 'HASH' )
   {  
      foreach my $field ( $self->fields )
      {  
         my $field_name = $field->name; 
         # Trim values and move to "input" slot
         if ( exists $input->{$field_name} )
         {  
            $field->input( $input->{$field_name} )
         }
         elsif( $field->DOES('HTML::FormHandler::Field::Repeatable') )
         {
            $field->clear_other;
         }
         elsif ( $field->has_input_without_param )
         {  
            $field->input( $field->input_without_param );
         }
      }
   }
   $self->_fields_validate;
   my %value_hash;
   for my $field ( $self->fields )
   {  
      next if $field->noupdate;
      $value_hash{ $field->accessor } = $field->value if $field->has_value;
   }
   $self->value( \%value_hash );
}


no Moose::Role;
1;
