package HTML::FormHandler::Page;

use Moose;
with 'HTML::FormHandler::Pages';

has 'name' => ( is => 'ro', isa => 'Str' );

has 'form'      => (
    isa => 'HTML::FormHandler',
    is => 'rw',
    weak_ref => 1,
    predicate => 'has_form',
);

has 'fields' => (
    traits     => ['Array'],
    isa        => 'ArrayRef[Str]',
    is         => 'rw',
    default    => sub { [] },
    handles   => {
        all_fields => 'elements',
        clear_fields => 'clear',
        push_field => 'push',
        num_fields => 'count',
        has_fields => 'count',
    }
);

sub field {
    my ( $self, $field_name ) = @_;

    return $self->form->field($field_name);
}


1;
