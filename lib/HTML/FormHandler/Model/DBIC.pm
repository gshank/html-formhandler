package HTML::FormHandler::Model::DBIC;

use Moose;
extends 'HTML::FormHandler';
use Carp;
use UNIVERSAL::require;
use DBIx::Class::ResultClass::HashRefInflator;
use DBIx::Class::ResultSet::RecursiveUpdate;
use Scalar::Util qw(blessed);

our $VERSION = '0.03';

=head1 NAME

HTML::FormHandler::Model::DBIC - Model class for FormHandler using DBIx::Class

=head1 SYNOPSIS

Subclass your form from HTML::FormHandler::Model::DBIC:

    package MyApp:Form::User;

    use Moose;
    extends 'HTML::FormHandler::Model::DBIC';

There are two ways to get a valid DBIC model: specify the 'item_id' (primary key),
'item_class' (or source_name), and 'schema', or pass in an 'item'.

You can specify the "item_class" in your form: 

    # Associate this form with a DBIx::Class result class
    has '+item_class' => ( default => 'User' ); # 'User' is the DBIC source_name 

The 'item_id' and 'schema' must be passed in when the form is used in your
controller.

If an 'item' is passed in, the 'item_id', 'item_class', and 'schema' will
be derived from the 'item'.

To use FormHandler to create new database records, pass in undef for the item_id,
and supply an 'item_class' and 'schema', or pass in an empty row (using
the resultset 'new_result' method).

The field names in the field_list of your form should match column, relationship,
or accessor names in your DBIx::Class result source.

=head1 DESCRIPTION

This DBIC model for HTML::FormHandler will save form fields automatically to 
the database, will retrieve selection lists from the database 
(with type => 'Select' and a fieldname containing a single relationship, 
or type => 'Multiple' and a many_to_many relationship), 
and will save the selected values (one value for 'Select', multiple 
values in a mapping table for a 'Multiple' field). 

This model supports using DBIx::Class result_source accessors just as
if they were standard columns. This allows you to provide alternative
getters and setters for use in your form.

Since the forms that use this model are subclasses of it, you can subclass
any of the subroutines to provide custom functionality.

More information is available from:

L<HTML::FormHandler>

L<HTML::FormHandler::Manual>

L<HTML::FormHandler::Field>

=head1 METHODS

=head2 schema

Stores the schema that is either passed in, created from
the model name in the controller, or created from the
Catalyst context and the item_class in the plugin.

=cut

has 'schema' => (
   is      => 'rw',
);
has 'source_name' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   builder => 'build_source_name'
);

# tell Moose to make this class immutable
HTML::FormHandler::Model::DBIC->meta->make_immutable;

=head2 validate_model

The place to put validation that requires database-specific lookups.
Subclass this method in your form. Validation of unique fields is 
called from this method.

=cut

sub validate_model
{
   my ($self) = @_;
   return unless $self->validate_unique;
   return 1;
}

sub clear_model
{
   my $self = shift;
   $self->item(undef);
   $self->item_id(undef);
}

=head2 update_model

Updates the database. If you want to do some extra
database processing (such as updating a related table) this is the
method to subclass in your form.

This routine allows the use of non-database (non-column, non-relationship) 
accessors in your result source class. It identifies form fields as column,
relationship, select, multiple, or other. Column and other fields are 
processed and update is called on the row. Then relationships are processed.

If the row doesn't exist (no primary key or row object was passed in), then
a row is created using "create" and the fields identified as columns passed
in a hashref, followed by "other" fields and relationships.

=cut

sub update_model
{
    my $self = shift;
    my $item   = $self->item;
    my $source = $self->source;

    warn "HFH: update_model for ", $self->name, "\n" if $self->verbose;
    #warn "fif: " . Dumper ( $self->fif ); use Data::Dumper;
    my %update_params = ( 
        resultset => $self->resultset, 
        updates => $self->values,
    );
    $update_params{ object } = $self->item if $self->item;
    my $new_item = DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update( %update_params );
    $new_item->discard_changes;
    $self->item($new_item);
    return $new_item;
}


=head2 guess_field_type

This subroutine is only called for "auto" fields, defined like:

    return {
       auto_required => ['name', 'age', 'sex', 'birthdate'],
       auto_optional => ['hobbies', 'address', 'city', 'state'],
    };

Pass in a column and it will guess the field type and return it.

Currently returns:
    DateTime     - for a has_a relationship that isa DateTime
    Select       - for a has_a relationship
    Multiple     - for a has_many

otherwise:
    DateTimeDMYHM   - if the field ends in _time
    Text            - otherwise

Subclass this method to do your own field type assignment based
on column types. This routine returns either an array or type string. 

=cut

sub guess_field_type
{
   my ( $self, $column ) = @_;
   my $source = $self->source;
   my @return;

   #  TODO: Should be able to use $source->column_info

   # Is it a direct has_a relationship?
   if (
      $source->has_relationship($column)
      && (  $source->relationship_info($column)->{attrs}->{accessor} eq 'single'
         || $source->relationship_info($column)->{attrs}->{accessor} eq 'filter' )
      )
   {
      my $f_class = $source->related_class($column);
      @return =
         $f_class->isa('DateTime')
         ? ('DateTime')
         : ('Select');
   }
   # Else is it has_many?
   elsif ( $source->has_relationship($column)
      && $source->relationship_info($column)->{attrs}->{accessor} eq 'multi' )
   {
      @return = ('Multiple');
   }
   elsif ( $column =~ /_time$/ )    # ends in time, must be time value
   {
      @return = ('DateTime');
   }
   else                             # default: Text
   {
      @return = ('Text');
   }

   return wantarray ? @return : $return[0];
}

=head2 lookup_options

This method is used with "Single" and "Multiple" field select lists 
("single", "filter", and "multi" relationships).
It returns an array reference of key/value pairs for the column passed in.
The column name defined in $field->label_column will be used as the label.
The default label_column is "name".  The labels are sorted by Perl's cmp sort.

If there is an "active" column then only active values are included, except 
if the form (item) has currently selected the inactive item.  This allows
existing records that reference inactive items to still have those as valid select
options.  The inactive labels are formatted with brackets to indicate in the select
list that they are inactive.

The active column name is determined by calling:
    $active_col = $form->can( 'active_column' )
        ? $form->active_column
        : $field->active_column;

This allows setting the name of the active column globally if
your tables are consistantly named (all lookup tables have the same
column name to indicate they are active), or on a per-field basis.

The column to use for sorting the list is specified with "sort_column". 
The currently selected values in a Multiple list are grouped at the top
(by the Multiple field class).

=cut

sub lookup_options
{
   my ( $self, $field, $accessor_path ) = @_;

   return unless $self->schema;
   my $self_source = $self->get_source( $accessor_path );

   my $accessor = $field->accessor;

   # if this field doesn't refer to a foreign key, return
   my $f_class;
   my $source;
   if ($self_source->has_relationship($accessor) )
   {
      $f_class = $self_source->related_class($accessor);
      $source = $self->schema->source($f_class);
   }
   elsif ($self->resultset->new_result({})->can("add_to_$accessor") )
   {
      # Multiple field with many_to_many relationship
      $source = $self_source->resultset->new_result({})->$accessor->result_source;
   }
   return unless $source; 

   my $label_column = $field->label_column;
   return unless $source->has_column($label_column);

   my $active_col = $self->active_column || $field->active_column;
   $active_col = '' unless $source->has_column($active_col);
   my $sort_col = $field->sort_column;
   $sort_col = defined $sort_col && $source->has_column($sort_col) ? $sort_col : $label_column;

   my ($primary_key) = $source->primary_columns;

   # If there's an active column, only select active OR items already selected
   my $criteria = {};
   if ($active_col)
   {
      my @or = ( $active_col => 1 );

      # But also include any existing non-active
      push @or, ( "$primary_key" => $field->init_value )
         if $self->item && defined $field->init_value;
      $criteria->{'-or'} = \@or;
   }

   # get an array of row objects
   my @rows =
      $self->schema->resultset( $source->source_name )
      ->search( $criteria, { order_by => $sort_col } )->all;
   my @options;
   foreach my $row (@rows)
   {
      my $label = $row->$label_column;
      next unless $label;   # this means there's an invalid value
      push @options, $row->id, $active_col && !$row->$active_col ? "[ $label ]" : "$label";
   }
   return \@options;
}

=head2 init_value

This method sets a field's value (for $field->value).

This method is not called if a method "init_value_$field_name" is found 
in the form class - that method is called instead.

=cut

sub init_value
{
   my ( $self, $field, $value ) = @_;
   if( ref $value eq 'ARRAY' ){
       $value = [ map { $self->_fix_value( $field, $_ ) } @$value ];
   }
   else{
       $value = $self->_fix_value( $field, $value );
   }
   $field->init_value($value);
   $field->value($value);
}

sub _fix_value 
{
   my ( $self, $field, $value ) = @_;
   if( blessed $value && $value->isa('DBIx::Class') ){
       return $value->id;
   }
   return $value;
}

=pod

sub _get_pk_for_related {
    my ( $self, $object, $relation ) = @_;

    my $source = $object->result_source;
    my $result_source = $self->_get_related_source( $source, $relation );
    return $result_source->primary_columns;
}

=cut

sub _get_related_source {
    my ( $self, $source, $name ) = @_;

    if( $source->has_relationship( $name ) ){
        return $source->related_source( $name );
    }
    # many to many case
    my $row = $source->resultset->new({});
    if ( $row->can( $name ) and $row->can( 'add_to_' . $name ) and $row->can( 'set_' . $name ) ){
        return $row->$name->result_source;
    }
    return;
}

=head2 validate_unique

For fields that are marked "unique", checks the database for uniqueness.

=cut

sub validate_unique
{
   my ($self) = @_;

   my $rs          = $self->resultset;
   my $found_error = 0;

   for my $field ( $self->fields )
   {
      next unless $field->unique;
      next if $field->has_errors;
      my $value = $field->value;
      next unless defined $value;
      my $accessor   = $field->accessor;

      # look for rows with this value 
      my $count = $rs->search( { $accessor => $value } )->count;
      # not found, this one is unique
      next if $count < 1;
      # found this value, but it's the same row we're updating
      next
         if $count == 1
            && $self->item_id 
            && $self->item_id eq $rs->search( { $accessor => $value } )->first->id;
      my $field_error = $field->unique_message || 'Duplicate value for ' . $field->label;
      $field->add_error( $field_error );
      $found_error++;
   }

   return $found_error;
}

=head2 build_item

This is called first time $form->item is called.
If using the Catalyst plugin, it sets the DBIx::Class schema from
the Catalyst context, and the model specified as the first part
of the item_class in the form. If not using Catalyst, it uses
the "schema" passed in on "new".

It then does:  

    return $self->resultset->find( $self->item_id );

If a database row for the item_id is not found, item_id will be set to undef.

=cut

sub build_item
{
   my $self = shift;

   my $item_id = $self->item_id or return;
   my $item = $self->resultset->find( ref $item_id eq 'ARRAY' ? 
                @{$item_id} : $item_id);
   $self->item_id(undef) unless $item;
   return $item;
}

sub set_item
{
   my ( $self, $item ) = @_;
   return unless $item;
   # when the item (DBIC row) is set, set the item_id, item_class
   # and schema from the item
   if( $item->id )
   { $self->item_id($item->id); }
   else
   { $self->clear_item_id; }
   $self->item_class( $item->result_source->source_name );
   $self->schema( $item->result_source->schema );
}

sub set_item_id
{
   my ( $self, $item_id ) = @_;
   # if a new item_id has been set
   # clear an existing item
   if( defined $self->item )
   {
      $self->clear_item
         if( !defined $item_id || 
             (ref $item_id eq 'ARRAY' &&
              join('', @{$item_id}) ne join('', $self->item->id)) ||
             (ref \$item_id eq 'SCALAR' && 
              $item_id ne $self->item->id));
   }
}


sub build_source_name
{
   my $self = shift;
   return $self->item_class;
}

=head2 source

Returns a DBIx::Class::ResultSource object for this Result Class.

=cut

sub source
{
   my ( $self, $f_class ) = @_;
   return $self->schema->source( $self->source_name || $self->item_class );
}

=head2 resultset

This method returns a resultset from the "item_class" specified
in the form, or from the foreign class that is retrieved from
a relationship.

=cut

sub resultset
{
   my ( $self, $f_class ) = @_;
   die "You must supply a schema for your FormHandler form" unless $self->schema;
   return $self->schema->resultset( $self->source_name || $self->item_class );
}

=pod

sub compute_model_stuff {
    my ( $self, $field, $source ) = @_;
    if( ! $source ){
        return if !$self->schema;
        $source = $self->source;
    }
    return $self->_get_related_source( $source, $field->accessor );
}

=cut


sub new_lookup_options
{
   my ( $self, $field, $accessor_path ) = @_;

   my $source = $self->get_source( $accessor_path );
   $self->lookup_options( $field, $source );
}

sub get_source
{
   my ( $self, $accessor_path ) = @_;
   return unless $self->schema;
   my $source = $self->source;
   return $source unless $accessor_path;
   my @accessors = split /\./, $accessor_path;
   for my $accessor ( @accessors ) 
   {
       $source = $self->_get_related_source( $source, $accessor );
       die "unable to get source for $accessor" unless $source;
   }
   return $source;
}
 

=head1 SUPPORT

See L<HTML::FormHandler>

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

Based on the original source code of L<Form::Processor::Model> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
