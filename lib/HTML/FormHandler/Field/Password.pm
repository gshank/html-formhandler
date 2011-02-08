package HTML::FormHandler::Field::Password;
# ABSTRACT: password field

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.04';

=head1 DESCRIPTION

The password field has a default minimum length of 6, which can be
easily changed:

  has_field 'password' => ( type => 'Password', minlength => 7 );

It does not come with additional default checks, since password
requirements vary so widely. There are a few constraints in the
L<HTML::FormHandler::Types> modules which could be used with this
field:  NoSpaces, WordChars, NotAllDigits.
These constraints can be used in the field definitions 'apply':

   use HTML::FormHandler::Types ('NoSpaces', 'WordChars', 'NotAllDigits' );
   ...
   has_field 'password' => ( type => 'Password',
          apply => [ NoSpaces, WordChars, NotAllDigits ],
   );

You can add your own constraints in addition, of course.

If a password field is not required, then the field will be marked 'noupdate',
to prevent a null from being saved into the database.

=head2 ne_username

Set this attribute to the name of your username field (default 'username')
if you want to check that the password is not the same as the username.
Does not check by default.

=cut

has '+widget'           => ( default => 'password' );
has '+password'         => ( default => 1 );
has 'ne_username'       => ( isa     => 'Str', is => 'rw' );

our $class_messages = {
    'required' => 'Please enter a password in this field',
    'password_ne_username' => 'Password must not match [_1]',
};

sub get_class_messages  {
    my $self = shift;
    my $messages = {
        %{ $self->next::method },
        %$class_messages,
    };
    $messages->{required} = $self->required_message
        if $self->required_message;
    return $messages;
}


after 'validate_field' => sub {
    my $self = shift;

    if ( !$self->required && !( defined( $self->value ) && length( $self->value ) ) ) {
        $self->noupdate(1);
        $self->clear_errors;
    }
};

sub validate {
    my $self = shift;

    $self->noupdate(0);
    return unless $self->next::method;

    my $value = $self->value;
    if ( $self->form && $self->ne_username ) {
        my $username = $self->form->get_param( $self->ne_username );
        return $self->add_error( $self->get_message('password_ne_username'), $self->ne_username  )
            if $username && $username eq $value;
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
