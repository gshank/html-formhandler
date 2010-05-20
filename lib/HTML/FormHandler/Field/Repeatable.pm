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

or use 'contains' with single fields which are compound fields:

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

The array of elements will be in C<< $form->field('addresses')->fields >>.
The subfields of the elements will be in a fields array in each element.

   foreach my $element ( $form->field('addresses')->fields )
   {
      foreach my $field ( $element->fields )
      {
         # do something
      }
   }

Every field that has a 'fields' array will also have an 'error_fields' array
containing references to the fields that contain errors.

Note that after updates to the database the fields will be reloaded. This means
that the array indexes ( the '3' in C<< $form->field('addresses.3') >> ) may
not be the same if there have been changes since the fields were initially 
loaded.

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

has 'contains' => (
    isa       => 'HTML::FormHandler::Field',
    is        => 'rw',
    predicate => 'has_contains'
);

has 'num_when_empty' => ( isa => 'Int',  is => 'rw', default => 1 );
has 'index'          => ( isa => 'Int',  is => 'rw', default => 0 );
has 'auto_id'        => ( isa => 'Bool', is => 'rw', default => 0 );
has '+reload_after_update' => ( default => 1 );
has 'is_repeatable' => ( is => 'ro', default => 1 );

sub _fields_validate {
    my $self = shift;
    # loop through array of fields and validate
    my @value_array;
    foreach my $field ( $self->all_fields ) {
        next if ( $field->inactive && !$field->_active ); 
        # Validate each field and "inflate" input -> value.
        $field->validate_field;    # this calls the field's 'validate' routine
        push @value_array, $field->value;
    }
    $self->_set_value( \@value_array );
}

sub init_state {
    my $self = shift;

    # must clear out instances built last time
    unless ( $self->has_contains ) {
        if ( $self->num_fields == 1 && $self->field('contains') ) {
            $self->contains( $self->field('contains') );
        }
        else {
            $self->contains( $self->create_element );
        }
    }
    $self->clear_fields;
}

sub create_element {
    my ($self) = @_;
    my $instance = Instance->new(
        name   => 'contains',
        parent => $self,
        form   => $self->form,
        type   => 'Repeatable::Instance',
    );
    # copy the fields from this field into the instance
    $instance->add_field( $self->all_fields );
    if ( $self->auto_id ) {
        unless ( grep $_->can('is_primary_key') && $_->is_primary_key, $instance->all_fields )
        {
            my $field = HTML::FormHandler::Field->new( type => 'PrimaryKey', name => 'id' );
            $instance->add_field($field);
        }
    }
    $_->parent($instance) for $instance->all_fields;
    return $instance;
}

sub clone_element {
    my ( $self, $index ) = @_;

    my $field = $self->contains->clone( errors => [], error_fields => [] );
    $field->name($index);
    $field->parent($self);
    if ( $field->has_fields ) {
        $self->clone_fields( $field, [ $field->all_fields ] );
    }
    return $field;
}

sub clone_fields {
    my ( $self, $parent, $fields ) = @_;
    my @field_array;
    $parent->fields( [] );
    foreach my $field ( @{$fields} ) {
        my $new_field = $field->clone( errors => [], error_fields => [] );
        if ( $new_field->has_fields ) {
            $self->clone_fields( $new_field, [ $new_field->all_fields ] );
        }
        $new_field->parent($parent);
        $parent->add_field($new_field);
    }
}

# params exist and validation will be performed (later)
sub _result_from_input {
    my ( $self, $result, $input ) = @_;

    $self->init_state;
    $result->_set_input($input);
    $self->_set_result($result);
    # if Repeatable has array input, need to build instances
    $self->fields( [] );
    if ( ref $input eq 'ARRAY' ) {
        # build appropriate instance array
        my $index = 0;
        foreach my $element ( @{$input} ) {
            next unless $element;
            my $field = $self->clone_element( $index );
            my $result = HTML::FormHandler::Field::Result->new(
                name   => $index,
                parent => $self->result
            );
            $result = $field->_result_from_input( $result, $element, 1 );
            $self->result->add_result($result);
            $self->add_field($field);
            $index++;
        }
        $self->index($index);
    }
    $self->result->_set_field_def($self);
    return $self->result;
}

# this is called when there is an init_object or an db item with values
sub _result_from_object {
    my ( $self, $result, $values ) = @_;

    return $self->_result_from_fields( $result ) 
        if ( $self->num_when_empty > 0 && !$values );
    $self->item($values);
    $self->init_state;
    $self->_set_result($result);
    # Create field instances and fill with values
    my $index = 0;
    my @new_values;
    $self->fields( [] );
    $values = [$values] if ( $values && ref $values ne 'ARRAY' );
    foreach my $element ( @{$values} ) {
        next unless $element;
        my $field = $self->clone_element( $index );
        my $result =
            HTML::FormHandler::Field::Result->new( name => $index, parent => $self->result );
        $result = $field->_result_from_object( $result, $element );
        push @new_values, $result->value;
        $self->add_field($field);
        $self->result->add_result( $field->result );
        $index++;
    }
    $self->index($index);
    $values = \@new_values if scalar @new_values;
    $self->_set_value($values);
    $self->result->_set_field_def($self);
    return $self->result;
}

# create an empty form
sub _result_from_fields {
    my ( $self, $result ) = @_;

    $self->init_state;
    $self->_set_result($result);
    my $count = $self->num_when_empty;
    my $index = 0;
    # build empty instance
    $self->fields( [] );
    while ( $count > 0 ) {
        my $field = $self->clone_element( $index );
        my $result =
            HTML::FormHandler::Field::Result->new( name => $index, parent => $self->result );
        $result = $field->_result_from_fields($result);
        $result->add_result( $field->result ) if $result;
        $self->add_field($field);
        $index++;
        $count--;
    }
    $self->index($index);
    $self->result->_set_field_def($self);
    return $result;
}

before 'value' => sub {
    my $self = shift;
    my @pk_elems = map { $_->accessor } grep { $_->has_flag('is_primary_key') } $self->contains->all_fields
        if $self->contains->has_flag('is_compound');
    my $value = $self->result->value;
    my @new_value;
    foreach my $element ( @{$value} ) {
        next unless $element;
        if( ref $element eq 'HASH' ) {
            foreach my $pk ( @pk_elems ) {
                delete $element->{$pk}
                   if exists $element->{$pk} && (!defined $element->{$pk} || $element->{$pk} eq '');
            }
            next unless keys %$element;
            next unless grep { defined $_ && $_ ne '' } values %$element;
        }
        push @new_value, $element;
    }
    $self->_set_value(\@new_value);
};

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
