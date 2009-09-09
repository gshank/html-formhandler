package    # hide from Pause
    HTML::FormHandler::Field::Repeatable::Instance;

use Moose;
extends 'HTML::FormHandler::Field::Compound';

=head1 NAME

HTML::FormHandler::Field::Repeatable::Instance

=head1 SYNOPSIS

This is a simple container class to hold an instance of a Repeatable field.
It will have a name like '0', '1'... Users should not need to use this class.

=cut

# this class does not have a 'real' accessor
sub full_accessor {
    my $field = shift;

    my $parent = $field->parent || return '';
    return $parent->full_accessor;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
