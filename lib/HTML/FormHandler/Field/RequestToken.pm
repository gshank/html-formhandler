package HTML::FormHandler::Field::RequestToken;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Hidden';

use namespace::autoclean;

use Crypt::CBC;
use MIME::Base64 qw(decode_base64 encode_base64);
use Moose::Util::TypeConstraints qw(class_type);
use Try::Tiny;

has '+required' => ( default => 1 );

has '+default_method' => ( default => sub { \&get_token });

=head1 NAME

HTML::FormHandler::Field::RequestToken - Hidden text field which contains
a unique time-stamped token

=head1 SYNOPSIS

    with 'HTML::FormHandler::Field::Role::RequestToken';
    ...
    has_field '_token' => (
        type => 'RequestToken',
    );

=head1 DESCRIPTION

This field is for preventing CSRF attacks.  It contains
an encrypted token containing an expiration time for the form.
No data needs to be persisted in the user's session or on the
server.

=head1 ATTRIBUTES

=head2 expiration_time

Length of time (in seconds) that token will be accepted as valid from
the time it is initially generated. Defaults to C<3600>.

=cut

has 'expiration_time' => (
  is      => 'rw',
  default => 3600
);

=head2 token_prefix

An optional string to prepend to the token value before encrypting it.
If specified, any received tokens must begin with this value to be
accepted as valid.  Defaults to an empty string.

Passed on form process. C<< $c->sessionid . '|' >>

=cut

has 'token_prefix' => (
  is      => 'rw',
  default => ''
);

=head2 crypto_key

Key to use to encrypt/decrypt the token payload.

=cut

has 'crypto_key' => (
  is      => 'rw',
  default => 'rEpLaCeMe',
);

=head2 crypto_cipher_type

The C<Crypt::CBC> cipher to use to encrypt/decrypt the token payload.
Defaults to C<Blowfish>.

=cut

has 'crypto_cipher_type' => (
  is      => 'rw',
  default => 'Blowfish',
);

=head2 message

Error message if token is missing/invalid.

=cut

has 'message' => (
  is      => 'rw',
  default => 'Form submission failed. Please try again.'
);

=head2 cipher

A C<Crypt::CBC> object to handle encrypting/decrypting the token payload.
If not specified, L</crypto_key> and L</crypto_cipher_type> will be
used to construct one.

=cut

has 'cipher' => (
  is      => 'ro',
  isa     => class_type('Crypt::CBC'),
  lazy    => 1,
  builder => '_build_cipher',
);

sub _build_cipher {
  my ($self) = @_;
  return Crypt::CBC->new(
    -key    => $self->crypto_key,
    -cipher => $self->crypto_cipher_type,
    -salt   => 1,
    -header => 'salt',
  );
}

sub validate {
  my ($self, $value) = @_;

  # If it's good, return it
  unless ( $self->verify_token($value) ) {
    $self->add_error();
  }

}

=head2 verify_token

Validates whether the specified token is currently valid for this form.

=cut

sub verify_token {
  my ($self, $token) = @_;

  return undef unless($token);

  my $form = $self->form;

  my $value = undef;
  try {
    $value = $self->cipher->decrypt(decode_base64($token));
    if ( my $prefix = $self->token_prefix ) {
      return undef unless ($value =~ s/^\Q$prefix\E//);
    }
  } catch {};

  return undef unless defined($value);
  return undef unless ( $value =~ /^\d+$/ );
  return undef if ( time() > $value );

  return 1;
}

=head2 get_token

Generates a new token and returns it.

=cut

sub get_token {
  my $self = shift;

  my $value = $self->token_prefix . (time() + $self->expiration_time);
  my $token = encode_base64($self->cipher->encrypt($value));
  $token =~ s/[\s\r\n]+//g;
  return $token;
}

__PACKAGE__->meta->make_immutable;

1;

