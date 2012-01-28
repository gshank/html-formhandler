package HTML::FormHandler::Field::Text;
# ABSTRACT: text field

use Moose;
extends 'HTML::FormHandler::Field';
our $VERSION = '0.01';

has 'size' => ( isa => 'Int|Undef', is => 'rw', default => '0' );
has 'maxlength' => ( isa => 'Int|Undef', is => 'rw' );
has 'maxlength_message' => ( isa => 'Str', is => 'rw',
    default => 'Field should not exceed [quant,_1,character]. You entered [_2]',
);
has 'minlength' => ( isa => 'Int|Undef', is => 'rw', default => '0' );
has 'minlength_message' => ( isa => 'Str', is => 'rw',
    default => 'Field must be at least [quant,_1,character]. You entered [_2]' );

has '+widget' => ( default => 'Text' );

our $class_messages = {
    'text_maxlength' => 'Field should not exceed [quant,_1,character]. You entered [_2]',
    'text_minlength' => 'Field must be at least [quant,_1,character]. You entered [_2]',
};

sub get_class_messages {
    my $self = shift;
    my $messages = {
        %{ $self->next::method },
        %$class_messages,
    };
    $messages->{text_minlength} = $self->minlength_message
        if $self->minlength_message;
    $messages->{text_maxlength} = $self->maxlength_message
        if $self->maxlength_message;
    return $messages;
}


sub validate {
    my $field = shift;

    return unless $field->next::method;
    my $value = $field->input;
    # Check for max length
    if ( my $maxlength = $field->maxlength ) {
        return $field->add_error( $field->get_message('text_maxlength'),
            $maxlength, length $value, $field->loc_label )
            if length $value > $maxlength;
    }

    # Check for min length
    if ( my $minlength = $field->minlength ) {
        return $field->add_error(
            $field->get_message('text_minlength'),
            $minlength, length $value, $field->loc_label )
            if length $value < $minlength;
    }
    return 1;
}

=head1 DESCRIPTION

This is a simple text entry field. Widget type is 'text'.

=head1 METHODS

=head2 size [integer]

This is used in constructing HTML. It determines the size of the input field.
The 'maxlength' field should be used as a constraint on the size of the field,
not this attribute.

=head2 minlength [integer]

This integer value, if non-zero, defines the minimum number of characters that must
be entered.

=head2 maxlength [integer]

A constraint on the maximum length of the text.

=head2 error messages

Set error messages (text_minlength, text_maxlength):

    has_field 'my_text' => ( type => 'Text', messages =>
        {  'text_minlength' => 'Field is too short',
           'text_maxlength' => 'Field is too long',
        } );

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
