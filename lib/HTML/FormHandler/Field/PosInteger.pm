package HTML::FormHandler::Field::PosInteger;

use Moose;
extends 'HTML::FormHandler::Field::Integer';
our $VERSION = '0.01';

__PACKAGE__->meta->make_immutable;

sub validate {
    my $self = shift;

    return unless $self->SUPER::validate;

    # remove plus sign.
    my $value = $self->input;
    if ( $value =~ s/^\+// ) {
        $self->input( $value );
    }
    return $self->add_error('Value must be a positive integer')
        unless $self->input >= 0;
    return 1;
}


=head1 NAME

HTML::FormHandler::Field::PosInteger - Validates input is a positive integer

=head1 DESCRIPTION

Tests that the input is an integer and has a postive value.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
