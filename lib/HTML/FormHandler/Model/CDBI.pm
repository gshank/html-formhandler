package  # hide from Pause
   HTML::FormHandler::Model::CDBI;

use Moose;
use Carp;
use Data::Dumper;
extends 'HTML::FormHandler';

our $VERSION = '0.02';

=head1 NAME

HTML::FormHandler::Model::CDBI - Class::DBI model class for HTML::FormHandler

=head1 SYNOPSIS

    package MyApplication::Form::User;
    use strict;
    use base 'HTML::FormHandler::Model::CDBI';


    # Associate this form with a CDBI class
    has '+item_class' => ( default => 'MyDB::User' );

    # Define the fields that this form will operate on
    sub field_list {
        return {
            [
                name        => 'Text',
                age         => 'PosInteger',
                sex         => 'Select',
                birthdate   => 'DateTimeDMYHM',
            ]
        };
    }

=head1 DESCRIPTION

A Class::DBI database model for HTML::FormHandler

I don't use CDBI, so this module almost certainly doesn't work.
It is only being left here as a starting point in case somebody is
interested in getting it to work.

Patches and tests gratefully accepted.


=head1 METHODS

=head2 item_class

The name of your database class.

=cut

HTML::FormHandler::Model::CDBI->meta->make_immutable;

=head2 init_item

This is called first time $form->item is called.
It does the equivalent of:

    return $self->item_class->retrieve( $self->item_id );

=cut

sub init_item
{
   my $self = shift;

   my $item_id = $self->item_id or return;
   return $self->item_class->retrieve($item_id);
}

sub BUILDARGS
{
   my ( $self, @args ) = @_;
   return {@args};
}

=head2 guess_field_type

Pass in a column and assigns field types.
Must set $self->item_class to return the related item class.
Returns the type in scalar context, returns the type and maybe the related table
in list context.

Currently returns:

    DateTime        - for a has_a relationship that isa DateTime
    Select          - for a has_a relationship
    Multiple        - for a has_many
    DateTime        - if the field ends in _time
    Text            - otherwise

=cut

sub guess_field_type
{
   my ( $self, $column, $class ) = @_;

   $class ||= $self->item_class;

   return unless $class && $class->isa('Class::DBI');

   my @return;

   # Is it a direct has_a relationship?
   if ( my $meta = $class->meta_info('has_a')->{$column} )
   {
      my $f_class = $meta->foreign_class;

      @return =
         $f_class->isa('DateTime')
         ? ('DateTime')
         : ( 'Select', $f_class );

      # Otherwise, check for has_many
   }
   elsif ( $meta = $class->meta_info('has_many')->{$column} )
   {

      my $f_class = $meta->foreign_class;
      # Is there a mapping table in between?  If so need to find the
      # actual class for lookups -- call recursively
      if ( @{ $meta->args->{mapping} } )
      {
         my $t;
         ( $t, $f_class ) = $self->guess_field_type( $meta->args->{mapping}[0], $f_class );
      }
      @return = ( 'Multiple', $f_class );
   }
   elsif ( $column =~ /_time$/ )
   {
      @return = ('DateTime');
   }
   else
   {
      @return = ('Text');
   }

   return wantarray ? @return : $return[0];
}

=head2 lookup_options

Returns a array reference of key/value pairs for the column passed in.
Calls $field->label_column to get the column name to use as the label.
The default is "name".  The labels are sorted by Perl's cmp sort.

If there is an "active" column then only active are included, with the exception
being if the form (item) has currently selected the inactive item.  This allows
existing records that reference inactive items to still have those as valid select
options.  The inactive labels are formatted with brackets to indicate in the select
list that they are inactive.

The active column name is determined by calling:

    $active_col = $form->can( 'active_column' )
        ? $form->active_column
        : $field->active_column;

Which allows setting the name of the active column globally if
your tables are consistantly named (all lookup tables have the same
column name to indicate they are active), or on a per-field basis.

In addition, if the foreign class is the same as the item's class (or the class returned
by item_class) then options pointing to item are excluded.  The reason for this is
for a table column that points to the same table (self referenced), such as a "parent"
column.  The assumption is that a record cannot be its own parent.

=cut

sub lookup_options
{
   my ( $self, $field ) = @_;

   my $class = $self->item_class or return;
   return unless $class->isa('Class::DBI');
   my $field_name = $field->name;
   my ( $type, $f_class ) = $self->guess_field_type( $field_name, $class );
   return unless $f_class;

   # label column
   my $label_column = $field->label_column;
   return unless $f_class->find_column($label_column);
   # active column
   my $active_col =
        $self->can('active_column')
      ? $self->active_column
      : $field->active_column;
   $active_col = '' unless $f_class->find_column($active_col);
   # sort column
   my $sort_col = $field->sort_column;
   $sort_col =
      defined $sort_col && $f_class->find_column($sort_col)
      ? $sort_col
      : $label_column;

   my $criteria    = {};
   my $primary_key = $f_class->primary_column;
   # In cases where the f_class is the same as the item's class don't
   # include item in the option list -- don't want to be able to have item point to itself
   # Obviously, this doesn't prevent circular references.
   $criteria->{"$primary_key"} = { '!=', $self->item->id }
      if $f_class eq ref $self->item;

   # If there's an active column, only select active OR items already selected
   if ($active_col)
   {
      my @or = ( $active_col => 1 );
      # But also include any existing non-active
      push @or, ( "$primary_key" => $field->init_value )    # init_value is scalar or array ref
         if $self->item && defined $field->init_value;
      $criteria->{'-or'} = \@or;
   }

   my @rows = $f_class->search( $criteria, { order_by => $sort_col } );

   return [
      map {
         my $label = $_->$label_column;
         $_->id, $active_col && !$_->$active_col ? "[ $label ]" : "$label"
         } @rows
   ];

}

=head2 init_value

Populate $field->value with object ids from the CDBI object.  If the column
expands to more than one object then an array ref is set.

=cut

sub init_value
{
   my ( $self, $field, $item ) = @_;

   my $column = $field->name;

   $item ||= $self->item;
   return if $field->writeonly;
   return
      unless $item
         && ( $item->can($column)
            || ( ref $item eq 'HASH' && exists $item->{$column} ) );
   my @values;
   if ( ref $item eq 'HASH' )
   {
      @values = $item->{$column} if ref($item) eq 'HASH';
   }
   elsif ( !$item->isa('Class::DBI') )
   {
      @values = $item->$column;
   }
   else
   {
      @values =
         map { ref $_ && $_->isa('Class::DBI') ? $_->id : $_ } $item->$column;
   }

   my $value = @values > 1 ? \@values : shift @values;
   $field->init_value($value);
   $field->value($value);
}

=head2 validate_model

Validates fields that are dependent on the model.
Currently, "unique" fields are checked  to make sure they are unique.

This validation happens after other form validation.  The form already has any
field values entered in $field->value at this point.

=cut

sub validate_model
{
   my ($self) = @_;

   return unless $self->validate_unique;
   return 1;
}

=head2 validate_unique

Checks that the value for the field is not currently in the database.

=cut

sub validate_unique
{
   my ($self) = @_;

   my @unique = map { $_->name } grep { $_->unique } $self->fields;
   return 1 unless @unique;

   my $item = $self->item;

   my $class = ref($item) || $self->item_class;
   my $found_error = 0;
   for my $field ( map { $self->field($_) } @unique )
   {
      next if $field->errors;
      my $value = $field->value;
      next unless defined $value;
      my $name = $field->name;
      # unique means there can only be on in the database like it.
      my $match = $class->search( { $name => $value } )->first || next;
      next if $self->items_same( $item, $match );
      my $field_error = $field->unique_message
         || 'Value must be unique in the database';
      $field->add_error($field_error);
      $found_error++;
   }
   return $found_error;
}

sub update_model
{
   my ($self) = @_;

   # Grab either the item or the object class.
   my $item = $self->item;
   my $class = ref($item) || $self->item_class;
   my $updated_or_created;

   # get a hash of all fields
   my %fields = map { $_->name, $_ } grep { !$_->noupdate } $self->fields;
   # First process the normal and has_a columns
   # as that data is directly stored in the object
   my %data;
   # Loads columns (including has_a)
   foreach my $col ( $class->columns('All') )
   {
      next unless exists $fields{$col};
      my $field = delete $fields{$col};
      # If the field is flagged "clear" then set to NULL.
      my $value = $field->value;
      if ($item)
      {
         my $cur = $item->$col;
         next unless $value || $cur;
         next if $value && $cur && $value eq $cur;
         $item->$col($value);
      }
      else
      {
         $data{$col} = $value;
      }
   }

   if ($item)
   {
      $item->update;
      $updated_or_created = 'updated';
   }
   else
   {
      $item = $class->create( \%data );
      $self->item($item);
      $updated_or_created = 'created';
   }

   # Now check for mapping/has_many in any left over fields

   for my $field_name ( keys %fields )
   {
      next unless $class->meta_info('has_many');
      next unless my $meta = $class->meta_info('has_many')->{$field_name};

      my $field = delete $fields{$field_name};
      my $value = $field->value;

      # Figure out which values to keep and which to add
      my %keep;
      %keep = map { $_ => 1 } ref $value ? @$value : ($value)
         if defined $value;

      # Get foreign class and its key that points to $class
      my $foreign_class = $meta->foreign_class;
      my $foreign_key   = $meta->args->{foreign_key};
      my $related_key   = $meta->args->{mapping}->[0];
      die "Failed to find related_key for field [$field] in class [$class]"
         unless $related_key;

      # Delete any items that are not to be kept
      for ( $foreign_class->search( { $foreign_key => $item } ) )
      {
         $_->delete unless delete $keep{ $_->$related_key };
      }

      # Add in new ones
      $foreign_class->create(
         {
            $foreign_key => $item,
            $related_key => $_,
         }
      ) for keys %keep;
   }

   # Save item in form object
   $self->item($item);
   return $item;
}

=head2 items_same

Returns true if the two passed in cdbi objects are the same object.
If both are undefined returns true.

=cut

sub items_same
{
   my ( $self, $item1, $item2 ) = @_;

   # returns true if both are undefined
   return 1 if not defined $item1 and not defined $item2;
   # return false if either undefined
   return unless defined $item1 and defined $item2;
   return $self->obj_key($item1) eq $self->obj_key($item2);
}

=head2 obj_key

returns a key for a given object, or undef if the object is undefined.

=cut

sub obj_key
{
   my ( $self, $item ) = @_;
   return join '|', $item->table,
      map { $_ . '=' . ( $item->$_ || '.' ) } $item->primary_columns;
}

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

Based on the original source code of L<Form::Processor::Model::CDBI> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
