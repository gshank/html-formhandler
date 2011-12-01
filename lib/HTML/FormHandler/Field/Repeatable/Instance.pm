package    # hide from Pause
    HTML::FormHandler::Field::Repeatable::Instance;
# ABSTRACT: used internally by repeatable fields

use Moose;
extends 'HTML::FormHandler::Field::Compound';

=head1 SYNOPSIS

This is a simple container class to hold an instance of a Repeatable field.
It will have a name like '0', '1'... Users should not need to use this class.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
