package HTML::FormHandler::Page;
# ABSTRACT: used in Wizard
use strict;
use warnings;

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

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
