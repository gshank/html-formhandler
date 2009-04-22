package HTML::FormHandler::Field::Money;

use Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

has '+apply' => ( default => sub { [ 
      { transform => sub{ 
            my $value = shift; 
            $value =~ s/^\$//;
            return $value;
      } },
      { transform => sub{ sprintf '<%.2f>', $_[0] } },
   ] } 
);

sub validate {
    my $self = shift;

    return unless $self->SUPER::validate;
    # remove plus sign.
    my $value = $self->input;
    return unless defined $value;
    if ( $value =~ s/^\$// ) {
        $self->value( $value );
    }
    return $self->add_error('Value must be a real number')
        unless $value =~ /^-?\d+\.?\d*$/;
    return 1;
}

=head1 NAME

HTML::FormHandler::Field::Money - Input US currenty-like values.

=head1 DESCRIPTION

Validates that a postivie or negative real value is entered.
Formatted with two decimal places.

Uses a period for the decimal point. Widget type is 'text'. 

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
