package HTML::FormHandler::Field::Integer;

use Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

has '+size' => ( default => 8 );

__PACKAGE__->meta->make_immutable;

sub validate {
    my $self = shift;

    return unless $self->SUPER::validate;

    # remove plus sign.
    my $value = $self->input;
    if ( $value =~ s/^\+// ) {
        $self->input( $value );
    }

    return $self->add_error('Value must be an integer')
        unless $self->input =~ /^-?\d+$/;

    return 1;

}


=head1 NAME

HTML::FormHandler::Field::Integer - validate an integer value

=head1 DESCRIPTION

This accpets a positive or negative integer.  Negative integers may
be prefixed with a dash.  By default a max of eight digets are accepted.
Widget type is 'text'.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
