package HTML::FormHandler::Widget::Wrapper::None;

use Moose::Role;

sub wrap_field { $_[2] } 

use namespace::autoclean;
1;
