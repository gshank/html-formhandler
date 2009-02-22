package HTML::FormHandler::Field::Password;

use Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

has '+widget' => ( default => 'password' );
has '+min_length' => ( default => 6 );
has '+password' => ( default => 1 );
has '+required_message' => ( default => 'Please enter a password in this field' );

__PACKAGE__->meta->make_immutable;

sub validate {
    my $self = shift;

    return unless $self->SUPER::validate;

    my $value = $self->input;

    return $self->add_error( 'Passwords must not contain spaces' )
        if $value =~ /\s/;
    return $self->add_error( 'Passwords must be made up from letters, digits, or the underscore' )
        if $value =~ /\W/;
    return $self->add_error( 'Passwords must not be all digits' )
        if $value =~ /^\d+$/;

    my $params = $self->form->params;
    for ('login', 'username') {
        next if $self->name eq $_;

        return $self->add_error( 'Password must not match ' . $_ )
          if $params->{$_} && $params->{$_} eq $value;
    }
    return 1;
}



=head1 NAME

HTML::FormHandler::Field::Password - Input a password

=head1 DESCRIPTION

Validates that it does not contain spaces (\s),
contains only wordcharacters (alphanumeric and underscore \w),
is not all digets, and is at least 6 characters long.

If there is another field called "login" or "username" will validate
that it does not match this field (preventing the same text for both login
and password.

=head2 Widget

Fields can be given a widget type that is used as a hint for
the code that renders the field.

This field's widget type is: "".

=head2 Subclass

Fields may inherit from other fields.  This field
inherits from:

=head1 AUTHORS

Bill Moseley

=head1 COPYRIGHT

See L<HTML::FormHandler> for copyright.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 SUPPORT / WARRANTY

L<HTML::FormHandler> is free software and is provided WITHOUT WARRANTY OF ANY KIND.
Users are expected to review software for fitness and usability.

=cut


no Moose;
1;
