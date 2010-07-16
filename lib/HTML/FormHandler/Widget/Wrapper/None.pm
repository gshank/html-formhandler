package HTML::FormHandler::Widget::Wrapper::None;
# ABSTRACT: wrapper that doesn't wrap

use Moose::Role;

sub wrap_field { $_[2] }

use namespace::autoclean;
1;
