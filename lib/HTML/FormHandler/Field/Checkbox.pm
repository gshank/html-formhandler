package HTML::FormHandler::Field::Checkbox;

use strict;
use warnings;

# ABSTRACT: a checkbox field type

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field';
our $VERSION = '0.02';

=head1 DESCRIPTION

This field is very similar to the Boolean Widget except that this
field allows other positive values besides 1. Since unselected
checkboxes do not return a parameter, fields with Checkbox type
will always be set to the 'input_without_param' default if they
do not appear in the form.

=head2 widget

checkbox

=head2 checkbox_value

In order to create the HTML for a checkbox, there must be a 'value="xx"'.
This value is specified with the 'checkbox_value' attribute, which
defaults to 1.

=head2 input_without_param

If the checkbox is not checked, it will be set to the value
of this attribute (the unchecked value). Default = 0. Because
unchecked checkboxes do not return anything in the HTTP parameters,
the absence of a checkbox key in the parameters hash forces this
field to this value. This means that Checkbox fields, unlike other
fields, will not be ignored if there is no input. If a particular
checkbox should not be processed for a particular form, you must
set 'inactive' to 1 instead.

Note that a checkbox is only 'checked' when the 'checkbox_value' is
provided. The 'value' for a non-checked checkbox is only really
useful for creating form values such as are stored in a database.

=cut

has '+widget'              => ( default => 'Checkbox' );
has 'checkbox_value'       => ( is      => 'rw', default => 1 );
has '+input_without_param' => ( default => 0 );
has '+type_attr'           => ( default => 'checkbox' );
has 'option_label'         => ( is => 'rw' );
has 'option_wrapper'       => ( is => 'rw' );

sub validate {
    my $self = shift;
    $self->add_error($self->get_message('required'), $self->loc_label) if( $self->required && !$self->value );
    return;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
