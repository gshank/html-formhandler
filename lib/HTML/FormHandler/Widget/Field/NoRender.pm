package HTML::FormHandler::Widget::Field::NoRender;
# ABSTRACT: no rendering widget

use Moose::Role;

sub render { '' }

use namespace::autoclean;
1;
