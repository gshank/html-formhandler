package HTML::FormHandler::Field::Boolean;

use Moose;
extends 'HTML::FormHandler::Field';
our $VERSION = '0.03';

has '+widget' => ( default => 'radio' );

__PACKAGE__->meta->make_immutable;

sub value {
    my $self = shift;

    my $v = $self->SUPER::value(@_);

    return unless defined $v;

    return $v ? 1 : 0;
}


=head1 NAME

HTML::FormHandler::Field::Boolean - A true or false field

=head1 DESCRIPTION

This field returnes undef if no value is defined, 0 if defined and false,
and 1 if defined and true. The widget type is 'radio'

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
