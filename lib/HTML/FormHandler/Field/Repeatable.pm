package HTML::FormHandler::Field::Repeatable;
# ABSTRACT: repeatable (array) field

use Moose;
extends 'HTML::FormHandler::Field::Compound';

use aliased 'HTML::FormHandler::Field::Repeatable::Instance';
use HTML::FormHandler::Field::PrimaryKey;
use HTML::FormHandler::Merge ('merge');
use Data::Clone ('data_clone');

=head1 SYNOPSIS

In a form, for an array of hashrefs, equivalent to a 'has_many' database
relationship.

  has_field 'addresses' => ( type => 'Repeatable' );
  has_field 'addresses.address_id' => ( type => 'PrimaryKey' );
  has_field 'addresses.street';
  has_field 'addresses.city';
  has_field 'addresses.state';

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

You can pass attributes to the 'contains' field by supplying an 'init_contains' hashref.

    has_field 'addresses' => ( type => 'Repeatable,
       init_contains => { wrapper_attr => { class => ['hfh', 'repinst'] } },
    );

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
   $form->field('addresses')->field('0')->field('city')

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

=head2 Complications

When new elements are created by a Repeatable field in a database form
an attempt is made to re-load the Repeatable field from the database, because
otherwise the repeatable elements will not have primary keys. Although this
works, if you have included other fields in your repeatable elements
that do *not* come from the database, the defaults/values must be
able to be loaded in a way that works when the form is initialized from
the database item. This is only an issue if you re-present the form
after the database update succeeds.

=head1 ATTRIBUTES

=over

=item  index

This attribute contains the next index number available to create an
additional array element.

=item num_when_empty

This attribute (default 1) indicates how many empty fields to present
in an empty form which hasn't been filled from parameters or database
rows.

=item num_extra

When the field results are built from an existing object (item or init_object)
an additional number of repeatable elements will be created equal to this
number. Default is 0.

=item add_extra

When a form is submitted and the field results are built from the input
parameters, it's not clear when or if an additional repeatable element might
be wanted. The method 'add_extra' will add an empty repeatable element.

    $form->process( params => {....} );
    $form->field('my_repeatable')->add_extra(1);

This might be useful if the form is being re-presented to the user.

=item setup_for_js

    setup_for_js => 1

Saves information in the form for javascript to use when adding repeatable elements.
If using the example javascript, you also must set 'do_wrapper' in the
Repeatable field and use the Bootstrap widget wrapper.
See t/repeatable/js.t for an example. See also
L<HTML::FormHandler::Render::RepeatableJs> and L<HTML::FormHandler::Field::AddElement>.

=back

=cut

has 'contains' => (
    isa       => 'HTML::FormHandler::Field',
    is        => 'rw',
    predicate => 'has_contains',
);

has 'init_contains' => ( is => 'rw', isa => 'HashRef', traits => ['Hash'],
    default => sub {{}},
    handles => { has_init_contains => 'count' },
);

has 'num_when_empty' => ( isa => 'Int',  is => 'rw', default => 1 );
has 'num_extra'      => ( isa => 'Int',  is => 'rw', default => 0 );
has 'setup_for_js'   => ( isa => 'Bool', is => 'rw' );
has 'index'          => ( isa => 'Int',  is => 'rw', default => 0 );
has 'auto_id'        => ( isa => 'Bool', is => 'rw', default => 0 );
has 'is_repeatable'  => ( isa => 'Bool', is => 'ro', default => 1 );
has '+widget'        => ( default => 'Repeatable' );

sub _fields_validate {
    my $self = shift;
    # loop through array of fields and validate
    my @value_array;
    foreach my $field ( $self->all_fields ) {
        next if ( $field->is_inactive );
        # Validate each field and "inflate" input -> value.
        $field->validate_field;    # this calls the field's 'validate' routine
        push @value_array, $field->value if $field->has_value;
    }
    $self->_set_value( \@value_array );
}

sub init_state {
    my $self = shift;

    # must clear out instances built last time
    unless ( $self->has_contains ) {
        if ( $self->num_fields == 1 && $self->field('contains') ) {
            $self->field('contains')->is_contains(1);
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

    my $instance;
    my $instance_attr = {
        name   => 'contains',
        parent => $self,
        type   => 'Repeatable::Instance',
        is_contains => 1,
    };
    # primary_key array is used for reloading after database update
    $instance_attr->{primary_key} = $self->primary_key
        if $self->has_primary_key;
    if( $self->has_init_contains ) {
        $instance_attr = merge( $self->init_contains, $instance_attr );
    }
    if( $self->form ) {
        $instance_attr->{form} = $self->form;
        $instance = $self->form->_make_adhoc_field(
            'HTML::FormHandler::Field::Repeatable::Instance',
            $instance_attr );
    }
    else {
        $instance = Instance->new( %$instance_attr );
    }
    # copy the fields from this field into the instance
    $instance->add_field( $self->all_fields );
    foreach my $fld ( $instance->all_fields ) {
        $fld->parent($instance);
    }

    # set required flag
    $instance->required( $self->required );

    # auto_id has no way to change widgets...deprecate this?
    if ( $self->auto_id ) {
        unless ( grep $_->can('is_primary_key') && $_->is_primary_key, $instance->all_fields ) {
            my $field;
            my $field_attr = { name => 'id', parent => $instance };
            if ( $self->form ) { # this will pull in the widget role
                $field_attr->{form} = $self->form;
                $field = $self->form->_make_adhoc_field(
                    'HTML::FormHandler::Field::PrimaryKey', $field_attr );
            }
            else { # the following won't have a widget role applied
                $field = HTML::FormHandler::Field::PrimaryKey->new( %$field_attr );
            }
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
    my $index = 0;
    if ( ref $input eq 'ARRAY' ) {
        # build appropriate instance array
        foreach my $element ( @{$input} ) {
            next if not defined $element; # skip empty slots
            my $field  = $self->clone_element($index);
            my $result = HTML::FormHandler::Field::Result->new(
                name   => $index,
                parent => $self->result
            );
            $result = $field->_result_from_input( $result, $element, 1 );
            $self->result->add_result($result);
            $self->add_field($field);
            $index++;
        }
    }
    $self->index($index);
    $self->_setup_for_js if $self->setup_for_js;
    $self->result->_set_field_def($self);
    return $self->result;
}

sub _setup_for_js {
    my $self = shift;
    return unless $self->form;
    my $full_name = $self->full_name;
    my $index_level =()= $full_name =~ /{index\d+}/g;
    $index_level++;
    my $field_name = "{index-$index_level}";
    my $field = $self->_add_extra($field_name);
    my $rendered = $field->render;
    # remove extra result & field, now that it's rendered
    $self->result->_pop_result;
    $self->_pop_field;
    # set the information in the form
    # $self->index is the index of the next instance
    $self->form->set_for_js( $self->full_name,
        { index => $self->index, html => $rendered, level => $index_level } );
}

# this is called when there is an init_object or a db item with values
sub _result_from_object {
    my ( $self, $result, $values ) = @_;

    return $self->_result_from_fields($result)
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
        my $field = $self->clone_element($index);
        my $result =
            HTML::FormHandler::Field::Result->new( name => $index, parent => $self->result );
        if( $field->has_inflate_default_method ) {
            $element = $field->inflate_default($element);
        }
        $result = $field->_result_from_object( $result, $element );
        push @new_values, $result->value;
        $self->add_field($field);
        $self->result->add_result( $field->result );
        $index++;
    }
    if( my $num_extra = $self->num_extra ) {
        while ($num_extra ) {
            $self->_add_extra($index);
            $num_extra--;
            $index++;
        }
    }
    $self->index($index);
    $self->_setup_for_js if $self->setup_for_js;
    $values = \@new_values if scalar @new_values;
    $self->_set_value($values);
    $self->result->_set_field_def($self);
    return $self->result;
}

sub _add_extra {
    my ($self, $index) = @_;

    my $field = $self->clone_element($index);
    my $result =
        HTML::FormHandler::Field::Result->new( name => $index, parent => $self->result );
    $result = $field->_result_from_fields($result);
    $self->result->add_result($result) if $result;
    $self->add_field($field);
    return $field;
}

sub add_extra {
    my ( $self, $count ) = @_;
    $count = 1 if not defined $count;
    my $index = $self->index;
    while ( $count ) {
        $self->_add_extra($index);
        $count--;
        $index++;
    }
    $self->index($index);
}

# create an empty field
sub _result_from_fields {
    my ( $self, $result ) = @_;

    # check for defaults
    if ( my @values = $self->get_default_value ) {
        return $self->_result_from_object( $result, \@values );
    }
    $self->init_state;
    $self->_set_result($result);
    my $count = $self->num_when_empty;
    my $index = 0;
    # build empty instance
    $self->fields( [] );
    while ( $count > 0 ) {
        my $field = $self->clone_element($index);
        my $result =
            HTML::FormHandler::Field::Result->new( name => $index, parent => $self->result );
        $result = $field->_result_from_fields($result);
        $self->result->add_result($result) if $result;
        $self->add_field($field);
        $index++;
        $count--;
    }
    $self->index($index);
    $self->_setup_for_js if $self->setup_for_js;
    $self->result->_set_field_def($self);
    return $result;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
