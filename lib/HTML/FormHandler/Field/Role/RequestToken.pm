package HTML::FormHandler::Field::Role::RequestToken;
# ABSTRACT: Role with Moose attributes necessary for the RequestToken field

use Moose::Role;

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
