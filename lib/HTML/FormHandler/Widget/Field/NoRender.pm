package HTML::FormHandler::Widget::Field::NoRender;

use Moose::Role;

sub render { '' }

no Moose::Role;
1;
