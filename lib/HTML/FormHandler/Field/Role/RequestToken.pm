package HTML::FormHandler::Field::Role::RequestToken;
use Moose::Role;

=head1 NAME

HTML::FormHandler::Field::Role::RequestToken

=head1 SYNOPSIS

Role with Moose attributes necessary for the RequestToken field

=cut

has 'token_prefix' => (
  is => 'rw',
  default => '',
);

has 'token_field_name' => (
  is => 'rw',
  default => '_token',
);

before 'update_fields' => sub {
  my $self = shift;

  my $token_field = $self->field($self->token_field_name);
  $token_field->token_prefix($self->token_prefix);
};

1;
