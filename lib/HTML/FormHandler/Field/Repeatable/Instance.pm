package    # hide from Pause
    HTML::FormHandler::Field::Repeatable::Instance;
# ABSTRACT: used internally by repeatable fields

use Moose;
extends 'HTML::FormHandler::Field::Compound';

=head1 SYNOPSIS

This is a simple container class to hold an instance of a Repeatable field.
It will have a name like '0', '1'... Users should not need to use this class.

=cut

sub BUILD {
    my $self = shift;

    $self->add_wrapper_class('hfh-repinst')
       unless $self->has_wrapper_class;

    return;
}

sub build_tags { return { wrapper => 1 }; }

has '+do_label' => ( default => 0 );
has '+do_wrapper' => ( default => 1 );
has '+no_value_if_empty' => ( default => 1 );

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
