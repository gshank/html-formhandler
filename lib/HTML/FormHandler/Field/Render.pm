package HTML::FormHandler::Field::Render;
# ABSTRACT: display only field

use Moose;
extends 'HTML::FormHandler::Field::NoValue';
use namespace::autoclean;

=head1 SYNOPSIS

This is an alternative to the Display field. It allows
you to provide a 'render_method', instead of using
the Display field's method of providing html.

=cut

has 'render_method' => (
    traits => ['Code'],
    is     => 'ro',
    isa    => 'CodeRef',
    predicate => 'does_render_method',
    handles => { 'render' => 'execute_method' },
    default => sub { \&default_render },
);

sub default_render {
    my $self = shift;
    return $self->html;
}

has 'html' => ( is => 'rw', isa => 'Str', default => '' );


__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
