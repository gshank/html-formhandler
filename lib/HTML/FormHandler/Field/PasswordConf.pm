package HTML::FormHandler::Field::PasswordConf;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.03';

=head1 NAME

HTML::FormHandler::Field::PasswordConf - Password confirmation

=head1 DESCRIPTION

This field needs to be declared after the related Password field (or more
precisely it needs to come after the Password field in the list returned by
the L<HTML::FormHandler/fields> method).

=head2 password_field

Set this attribute to the name of your password field (default 'password')

=cut

has '+widget'           => ( default => 'password' );
has '+password'         => ( default => 1 );
has '+required'         => ( default => 1 );
has '+required_message' => ( default => 'Please enter a password confirmation' );
has 'password_field'    => ( isa     => 'Str', is => 'rw', default => 'password' );
has 'pass_conf_message' => (
    isa     => 'Str',
    is      => 'rw',
    default => 'The password confirmation does not match the password'
);

sub validate {
    my $self = shift;

    my $value    = $self->value;
    my $password = $self->form->field( $self->password_field )->value;
    if ( $password ne $self->value ) {
        $self->add_error( $self->pass_conf_message );
        return;
    }
    return 1;
}

=head1 AUTHORS

See L<HTML::FormHandler> for authors.

=head1 COPYRIGHT

See L<HTML::FormHandler> for copyright.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
