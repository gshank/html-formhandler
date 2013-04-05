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

has '+inflate_default_method' => ( default => sub { \&textcsv_inflate_default } );
has '+deflate_value_method' => ( default => sub { \&textcsv_deflate_value } );

sub textcsv_inflate_default {
    my ( $self, $value ) = @_;
    if( defined $value && ref $value eq 'ARRAY' ) {
        my $new_value = join(',', @$value);
        return $new_value;
    }
    return $value;
}

sub textcsv_deflate_value {
    my ( $self, $value ) = @_;
    if ( defined $value && length $value ) {
        my @values = split(/,/, $value);
        return \@values;
    }
    return $value;
}

1;
