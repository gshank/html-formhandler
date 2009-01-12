package HTML::FormHandler::Field::Email;

use Moose;
extends 'HTML::FormHandler::Field';
use Email::Valid;
our $VERSION = '0.01';

__PACKAGE__->meta->make_immutable;

sub validate {
    my $self = shift;

    return unless $self->SUPER::validate;
    $self->input( lc $self->{input} );
    return $self->add_error('Email should be of the format [_1]', 'someuser@example.com')
        unless Email::Valid->address( $self->input );
    return 1;
}


=head1 NAME

HTML::FormHandler::Field::Email - Validates email uisng Email::Valid

=head1 DESCRIPTION

Validates that the input looks like an email address uisng L<Email::Valid>. 
Widget type is 'text'.

=head1 DEPENDENCIES

L<Email::Valid>

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
