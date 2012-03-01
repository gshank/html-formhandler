package HTML::FormHandler::Field::Float;
# ABSTRACT: validate an integer value

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.02';


has '+size'                 => ( default => 8 );
has 'precision'             => ( isa => 'Int|Undef', is => 'rw', default => 2 );
has 'decimal_symbol'        => ( isa => 'Str', is => 'rw', default => '.');
has 'decimal_symbol_for_db' => ( isa => 'Str', is => 'rw', default => '.');
has '+inflate_method'       => ( default => sub { \&inflate_float } );
has '+deflate_method'       => ( default => sub { \&deflate_float } );

our $class_messages = {
    'float_needed'      => 'Must be a number. May contain numbers, +, - and decimal separator \'[_1]\'',
    'float_size'        => 'Total size of number must be less than or equal to [_1], but is [_2]',
    'float_precision'   => 'May have a maximum of [quant,_1,digit] after the decimal point, but has [_2]',
};

sub get_class_messages {
    my $self = shift;
    return {
        %{ $self->next::method },
        %$class_messages,
    }
}

sub inflate_float {
    my ( $self, $value ) = @_;
    $value =~ s/^\+//;
    return $value;
}

sub deflate_float {
    my ( $self, $value ) = @_;
    my $symbol      = $self->decimal_symbol;
    my $symbol_db   = $self->decimal_symbol_for_db;
    $value =~ s/\Q$symbol_db\E/$symbol/x;
    return $value;
}

sub validate {
    my $field = shift;

    #return unless $field->next::method;
    my ($integer_part, $decimal_part) = ();
    my $value       = $field->value;
    my $symbol      = $field->decimal_symbol;
    my $symbol_db   = $field->decimal_symbol_for_db;

    if ($value =~ m/^-?([0-9]+)(\Q$symbol\E([0-9]+))?$/x) {     # \Q ... \E - All the characters between the \Q and the \E are interpreted as literal characters.
        $integer_part = $1;
        $decimal_part = $3;
    }
    else {
        return $field->add_error( $field->get_message('float_needed'), $symbol );
    }

    if ( my $allowed_size = $field->size ) {
        my $total_size = length($integer_part) + length($decimal_part);
        return $field->add_error( $field->get_message('float_size'),
            $allowed_size, $total_size )
            if $total_size > $allowed_size;
    }

    if ( my $allowed_precision = $field->precision ) {
        return $field->add_error( $field->get_message('float_precision'),
            $allowed_precision, length $decimal_part)
            if length $decimal_part > $allowed_precision;
    }

    # Inflate to database accepted format
    $value =~ s/\Q$symbol\E/$symbol_db/x;
    $field->_set_value($value);

    return 1;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;

__END__

=head1 DESCRIPTION

This accepts a positive or negative float/integer.  Negative numbers may
be prefixed with a dash.  By default a max of eight digits including 2 precision
are accepted. Default decimal symbol is ','.
Widget type is 'text'.

    # For example 1234,12 has size of 6 and precision of 2
    # and separator symbol of ','

    has_field 'test_result' => (
        type                    => 'FloatNumber',
        size                    => 8,               # Total size of number including decimal part.
        precision               => 2,               # Size of the part after decimal symbol.
        decimal_symbol          => '.',             # Decimal symbol accepted in web page form
        decimal_symbol_for_db   => '.',             # For inflation. Decimal symbol accepted in DB, which automatically converted to.
        range_start             => 0,
        range_end               => 100
    );

=head2 messages

   float_needed
   float_size
   float_precision

=cut
