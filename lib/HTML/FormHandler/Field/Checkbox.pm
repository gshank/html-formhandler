package HTML::FormHandler::Field::Checkbox;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field';
our $VERSION = '0.02';

=head1 NAME

HTML::FormHandler::Field::Checkbox - A checkbox field type

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

=cut

has '+widget'              => ( default => 'checkbox' );
has 'checkbox_value'       => ( is      => 'rw', default => 1 );
has '+input_without_param' => ( default => 0 );

sub value {
    my $field = shift;
    return $field->next::method(@_) if @_;
    my $v = $field->next::method();
    return defined $v ? $v : 0;
}

sub validate {
    my $self = shift;
    $self->add_error( $self->required_message ) if ( $self->required && !$self->value );
}

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
