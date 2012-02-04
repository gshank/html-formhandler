package HTML::FormHandler::Base;
# ABSTRACT: stub
use Moose;

with 'HTML::FormHandler::Widget::Form::Simple';

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
