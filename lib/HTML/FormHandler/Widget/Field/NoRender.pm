package HTML::FormHandler::Widget::Field::NoRender;
# ABSTRACT: no rendering widget
use Moose::Role;

=head1 SYNOPSIS

Renders a field as the empty string.

=cut

sub render { return ''; }

use namespace::autoclean;
1;
