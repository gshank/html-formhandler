package HTML::FormHandler::Widget::Field::NoRender;
# ABSTRACT: no rendering widget
use strict;
use warnings;
use Moose::Role;

=head1 SYNOPSIS

Renders a field as the empty string.

=cut

sub render { '' }

use namespace::autoclean;
1;
