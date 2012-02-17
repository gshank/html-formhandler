package HTML::FormHandler::Widget::Wrapper::None;
# ABSTRACT: wrapper that doesn't wrap

use Moose::Role;

sub wrap_field { "\n" . $_[2] }

use namespace::autoclean;
1;
