package HTML::FormHandler::Field::Password;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.02';

has '+widget' => ( default => 'password' );
has '+min_length' => ( default => 6 );
has '+password' => ( default => 1 );
has '+required_message' => ( default => 'Please enter a password in this field' );

apply ( [
   {  check => sub { $_[0] !~ /\s/ },
      message => 'Password can not contain spaces' },
   {  check => sub { $_[0] !~ /\W/ },
      message => 'Password must be made up of letters, digits, and underscores' },
   {  check => sub { $_[0] !~ /^\d+$/ },
      message => 'Password must be all digits' },
] );
__PACKAGE__->meta->make_immutable;

sub validate {
    my $self = shift;

    return unless $self->SUPER::validate;

    my $value = $self->value;
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
