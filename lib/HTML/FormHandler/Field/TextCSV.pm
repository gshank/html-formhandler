package HTML::FormHandler::Field::TextCSV;
# ABSTRACT: CSV Text field from multiple
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

=head1 NAME

HTML::FormHandler::Field::TextCSV

=head1 SYNOPSIS

A text field that takes multiple values from a database and converts
them to comma-separated values. This is intended for javascript fields
that require that, such as 'select2'.

=cut

has '+deflate_method' => ( default => sub { \&textcsv_deflate } );
has '+inflate_method' => ( default => sub { \&textcsv_inflate } );
has 'multiple' => ( isa => 'Bool', is => 'rw', default => '0' );
sub build_value_when_empty { [] }
sub _inner_validate_field {
    my $self = shift;
    my $value = $self->value;
    return unless $value;
    if ( ref $value ne 'ARRAY' ) {
        $value = [$value];
        $self->_set_value($value);
    }
}

sub textcsv_deflate {
    my ( $self, $value ) = @_;
    if( defined $value && length $value ) {
        my $value = ref $value eq 'ARRAY' ? $value : [$value];
        my $new_value = join(',', @$value);
        return $new_value;
    }
    return $value;
}

sub textcsv_inflate {
    my ( $self, $value ) = @_;
    if ( defined $value && length $value ) {
        my @values = split(/,/, $value);
        return \@values;
    }
    return $value;
}

__PACKAGE__->meta->make_immutable;
1;

