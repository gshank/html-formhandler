package HTML::FormHandler::Field::Text;

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
has 'min_length' => (
    isa     => 'Int|Undef',
    is      => 'rw',
    default => '0',
    reader  => '_min_length_r',
    writer  => '_min_length_w'
);    # for backcompat

sub min_length {
    my ( $self, $value ) = @_;
    warn "Please use the 'minlength' attribute - 'min_length' is deprecated";
    if ($value) {
        $self->_min_length_w($value);
    }
    return $self->_min_length_r;
}

has '+widget' => ( default => 'text' );

sub validate {
    my $field = shift;

    return unless $field->SUPER::validate;
    my $value = $field->input;
    # Check for max length
    if ( my $maxlength = $field->maxlength ) {
        return $field->add_error( $field->maxlength_message, 
            $maxlength, length $value, $field->loc_label )
            if length $value > $maxlength;
    }

    # Check for min length
    if ( my $minlength = $field->minlength || $field->_min_length_r ) {
        return $field->add_error(
            $field->minlength_message,
            $minlength, length $value, $field->loc_label )
            if length $value < $minlength;
    }
    return 1;
}

=head1 NAME

HTML::FormHandler::Field::Text - A simple text entry field

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

=head1 AUTHORS

Gerda Shank

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
