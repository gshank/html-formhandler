package HTML::FormHandler::Model::CDBI;

use Moose;
use Carp;
use Data::Dumper;
extends 'HTML::FormHandler';

our $VERSION = '0.07_1';

=head1 NAME

HTML::FormHandler::Model::CDBI - model class for HTML::FormHandler based on Class::DBI

=head1 SYNOPSIS

    package MyApplication::Form::User;
    use strict;
    use base 'HTML::FormHandler::Model::CDBI';


    # Associate this form with a CDBI class
    has '+item_class' => ( default => 'MyDB::User' );

    # Define the fields that this form will operate on
    sub profile {
        my $self = shift;

        return {
            required => {
                name        => 'Text',
                age         => 'PosInteger',
                sex         => 'Select',
                birthdate   => 'DateTimeDMYHM',
            },
            optional => {
                hobbies     => 'Multiple',
                address     => 'Text',
                city        => 'Text',
                state       => 'Select',
            },

            dependency => [
                [qw/ address city state /],
            ],
        };
    }

=head1 DESCRIPTION

This is a HTML::FormHandler::Model add-on module.  This module is for use with
Class::DBI objects.  A form is associated with one of your CDBI table classes
(e.g. Artists, Users) and then your forms can be populated with data from the
database row, and select options from has_a and many-to-many relationships are
also selected automatically.

Your application code calls the update_from_form() method to validate and (
if validation passes) to update or insert the row into the table.

Your form inherits from HTML::FormHandler::Model::CDBI as shown in the SYNOPSIS
instead of directly from HTML::FormHandler.


=head1 METHODS

=over 4

=item item_class

This method is typically overridden in your form class and relates the form
to a specific Class::DBI table class.  This is the mapping between the form and
the columns in the table the form operates on.

The module uses this information to lookup options in related tables for both
select and multiple select (many-to-many) relationships.

If not defined will attempt to use the class of $form->item, if set.

Typically, this method is overridden as shown above, and is all you need to do to
use this module.  This can also be a parameter when creating a form instance.


=cut


HTML::FormHandler::Model::CDBI->meta->make_immutable;

=item init_item

This is called first time $form->item is called.
It calls basically does:

    return $self->item_class->retrieve( $self->item_id );

But also validates that the item id matches /^\d+$/.  Override this method
in your form class (or form base class) if your ids do not match that pattern.

=cut

sub init_item {
    my $self = shift;

    #my $item_id = $self->item_id or return 0;
    my $item_id = $self->item_id or return;

    #return 0 unless $item_id =~ /^\d+$/;
    return unless $item_id =~ /^\d+$/;
    return $self->item_class->retrieve($item_id);
}

sub BUILDARGS {
    my ( $self, @args ) = @_;
    return {@args};
}

=item guess_field_type

Pass in a column and will try and determine the field type.
Currently only looks at CDBI relationships.  Would be nice to use the database
to determine the types as well.

Must set $self->item_class to return the related item class.

Returns the type in scalar context, returns the type and maybe the related table
in list context.

Currently returns:

    DateTimeDMYHM   - for a has_a relationship that isa DateTime
    Select          - for a has_a relationship
    Multiple        - for a has_many

otherwise:

    DateTimeDMYHM   - if the field ends in _time
    Text            - otherwise

=cut

# probably need to check $class->isa('Class::DBI').  Just haven't seen the need yet.

sub guess_field_type {
    my ( $self, $column, $class ) = @_;

    $class ||= $self->item_class;

    return unless $class && $class->isa('Class::DBI');

    my @return;

    # Is it a direct has_a relationship?
    if ( my $meta = $class->meta_info('has_a')->{$column} ) {
        my $f_class = $meta->foreign_class;

        @return =
            $f_class->isa('DateTime')
            ? ('DateTimeDMYHM')
            : ( 'Select', $f_class );

        # Otherwise, check for has_many
    }
    elsif ( $meta = $class->meta_info('has_many')->{$column} ) {

        my $f_class = $meta->foreign_class;

        # Is there a mapping table in between?  If so need to find the
        # actual class for lookups -- call recursively
        #

        if ( @{ $meta->args->{mapping} } ) {
            my $t;
            ( $t, $f_class ) =
                $self->guess_field_type( $meta->args->{mapping}[0], $f_class );
        }

        @return = ( 'Multiple', $f_class );

    }
    elsif ( $column =~ /_time$/ ) {
        @return = ('DateTimeDMYHM');

    }
    else {
        @return = ('Text');

    }

    return wantarray ? @return : $return[0];
}

=item lookup_options

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

sub lookup_options {
    my ( $self, $field ) = @_;

    my $class = $self->item_class or return;

    return unless $class->isa('Class::DBI');

    my $field_name = $field->name;

    my ( $type, $f_class ) = $self->guess_field_type( $field_name, $class );
    return unless $f_class;

    my $label_column = $field->label_column;

    return unless $f_class->find_column($label_column);

    my $active_col =
          $self->can('active_column')
        ? $self->active_column
        : $field->active_column;

    $active_col = '' unless $f_class->find_column($active_col);

    my $sort_col = $field->sort_column;
    $sort_col =
        defined $sort_col && $f_class->find_column($sort_col)
        ? $sort_col
        : $label_column;

    my $criteria = {};

    my $primary_key = $f_class->primary_column;

    # In cases where the f_class is the same as the item's class don't
    # include item in the option list -- don't want to be able to have item point to itself
    # Obviously, this doesn't prevent circular references.

    $criteria->{"$primary_key"} = { '!=', $self->item->id }
        if $f_class eq ref $self->item;

    # If there's an active column, only select active OR items already selected

    if ($active_col) {

        my @or = ( $active_col => 1 );

        # But also include any existing non-active

        push @or,
            ( "$primary_key" =>
                $field->init_value )    # init_value is scalar or array ref
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

=item init_value

Populate $field->value with object ids from the CDBI object.  If the column
expands to more than one object then an array ref is set.

=cut

sub init_value {
    my ( $self, $field, $item ) = @_;

    my $column = $field->name;

    $item ||= $self->item;

    return $item->{$column} if ref($item) eq 'HASH';

    # Use "can" instead of "find_column" because could be a related column
    return unless $item && $item->isa('Class::DBI') && $item->can($column);

    # @options can be a collection of CDBI objects (has_many) or a
    # CDBI objects get turned into IDs.  Should also check that it's not a compound
    # primary key.

    my @values =
        map { ref $_ && $_->isa('Class::DBI') ? $_->id : $_ } $item->$column;

    return @values;

}

=item update_from_form

    my $ok = $form->update_from_form( $parameter_hash );

Update or create the object from values in the form.

Any field names that are related to the class by "has_many" and have a mapping
table will be updated.  Validation is run unless validation has already been
run.  ($form->clear might need to be called if the $form object stays in memory
between requests.)

The update/create is done inside a transaction if the method
C<do_transaction()> is available.  It's recommended that your CDBI model class
supplies that method.

The actual update is done in the C<update_model> method.  Your form class can
override that method (but don't forget to call SUPER!) if you wish to do additional
database inserts or updates.  This is useful when a single form updates multiple tables.
(If you are doing much of that review your schema design....).  If anything goes wrong
in the update make sure you C<die>.  Assuming you have a standard C<do_transaction()>
method this will call a rollback.  You should no use C<do_transaction()> in your overridden
method unless is supports nested calls or you are not calling SUPER.

Pass in hash reference of parameters.

Returns false if form does not validate.  Very likely dies on database errors.

=cut

sub update_from_form {
    my ( $self, $params ) = @_;

    return unless $self->validate($params);

    # Should this be wrapped in an eval?  If so then should
    # call $item->discard_changes (when updating)
    if ( $self->item_class->can('do_transaction') ) {
        $self->item_class->do_transaction( sub { $self->update_model } );

    }
    else {
        $self->update_model;
    }

    return 1;
}

=item model_validate

Validates profile items that are dependent on the model.
Currently, "unique" fields are checked  to make sure they are unique.

This validation happens after other form validation.  The form already has any
field values entered in $field->value at this point.

=cut

sub model_validate {
    my ($self) = @_;

    return unless $self->validate_unique;

    return 1;
}

=item validate_unique

Checks that the value for the field is not currently in the database.

=cut

sub validate_unique {
    my ($self) = @_;

    my $unique_from_profile = $self->profile->{unique};
    my @unique_from_fields = map { $_->name } grep { $_->unique } $self->fields;
    my @unique = ( @$unique_from_profile, @unique_from_fields );
    return 1 unless @unique;

    my $item = $self->item;

    my $class = ref($item) || $self->item_class;

    my $found_error = 0;

    for my $field ( map { $self->field($_) } @unique ) {

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

sub update_model {
    my ($self) = @_;

    # Grab either the item or the object class.
    my $item = $self->item;
    my $class = ref($item) || $self->item_class;

    # get a hash of all fields
    my %fields = map { $_->name, $_ } grep { !$_->noupdate } $self->fields;

    # First process the normal and has_a columns
    # as that data is directly stored in the object

    my %data;

    # Loads columns (including has_a)
    foreach my $col ( $class->columns('All') ) {
        next unless exists $fields{$col};

        my $field = delete $fields{$col};

        # If the field is flagged "clear" then set to NULL.
        my $value = $field->clear ? undef : $field->value;

        if ($item) {
            my $cur = $item->$col;
            next unless $value || $cur;
            next if $value && $cur && $value eq $cur;
            $item->$col($value);
        }
        else {
            $data{$col} = $value;
        }
    }

    if ($item) {
        $item->update;
        $self->updated_or_created('updated');
    }
    else {
        $item = $class->create( \%data );
        $self->item($item);
        $self->updated_or_created('created');
    }

    # Now check for mapping/has_many in any left over fields

    for my $field_name ( keys %fields ) {
        next unless $class->meta_info('has_many');
        next unless my $meta = $class->meta_info('has_many')->{$field_name};

        my $field = delete $fields{$field_name};
        my $value = $field->value;

        my %keep;

        # Figure out which values to keep and which to add

        %keep = map { $_ => 1 } ref $value ? @$value : ($value)
            if defined $value;

        # Get foreign class and its key that points to $class
        my $foreign_class = $meta->foreign_class;
        my $foreign_key   = $meta->args->{foreign_key};
        my $related_key   = $meta->args->{mapping}->[0];

        # This limits to using a mapping table.  Hard to imagine an interface
        # for adding a has_many without a mapping table, but it could be a table
        # of just columns id, name, f_key, I suppose.

        die "Failed to find related_key for field [$field] in class [$class]"
            unless $related_key;

        # Delete any items that are not to be kept

        for ( $foreign_class->search( { $foreign_key => $item } ) ) {
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

    # Uncomment if want to update values from database from values
    # just saved to database.  Where this might have an effect it
    # with DateTime objects since the timezone coming out of the database
    # might be different then the timezone set after an updated.
    # (e.g from the db it might be DateTime::TimeZone::OffsetOnly, but
    #  from the form it might be DateTime::TimeZone::America::Los_Angeles.
    #  Both of which are determined by the timezone setting on the
    #  database and application server.
    #
    # $self->init_from_object;

    $self->reset_params;    # force reload of parameters from values

    return $item;
}

=item items_same

Returns true if the two passed in cdbi objects are the same object.
Can't trust that the Live_Object index is in use.


If both are undefined returns true.  But don't call it that way.

=cut

sub items_same {
    my ( $self, $item1, $item2 ) = @_;

    # returns true if both are undefined
    return 1 if not defined $item1 and not defined $item2;

    # return false if either undefined
    return unless defined $item1 and defined $item2;

    return $self->obj_key($item1) eq $self->obj_key($item2);
}

=item obj_key

returns a key for a given object, or undef if the object is undefined.

=cut

sub obj_key {
    my ( $self, $item ) = @_;
    return join '|', $item->table,
        map { $_ . '=' . ( $item->$_ || '.' ) } $item->primary_columns;
}

=back

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

Based on the original source code of L<Form::Processor::Field> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
