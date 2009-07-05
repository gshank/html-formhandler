package HTML::FormHandler::Field::Text;

use Moose;
extends 'HTML::FormHandler::Field';
our $VERSION = '0.01';

has 'size' => ( isa => 'Int|Undef', is => 'rw', default => '0' );
has 'maxlength' => ( isa => 'Int|Undef', is => 'rw' );
has 'minlength' => ( isa => 'Int|Undef', is => 'rw', default => '0' );
has 'min_length' => ( isa => 'Int|Undef', is => 'rw', default => '0', reader => '_min_length_r', writer => '_min_length_w' ); # for backcompat
sub min_length {
    my ( $self, $value ) = @_;
    warn "Please use the 'minlength' attribute - 'min_length' is deprecated";
    if( $value ){
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
    if ( my $size = $field->maxlength ) {
        return $field->add_error( 'Please limit to [quant,_1,character]. You submitted [_2]', $size, length $value )
            if length $value > $size;
    }

    # Check for min length
    if ( my $size = $field->minlength || $field->_min_length_r ) {
        return $field->add_error(
           'Input must be at least [quant,_1,character]. You submitted [_2]',
           $size, length $value )
            if length $value < $size;
    }
    return 1;
}

=head1 NAME

HTML::FormHandler::Field::Text - A simple text entry field

=head1 DESCRIPTION

This is a simple text entry field. Widget type is 'text'.

=head1 METHODS

=head2 size [integer]

This integer value, if non-zero, defines the max size in characters of the input field.
This setting may also be used in formatting the field in the user interface.

=head2 min_length [integer]

This integer value, if non-zero, defines the minimum number of characters that must
be entered.

=head1 AUTHORS

Gerda Shank

Based on the original source of L<Form::Processor::Field::Text> by Bill Moseley

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
