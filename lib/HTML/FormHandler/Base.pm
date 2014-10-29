package HTML::FormHandler::Base;
# ABSTRACT: stub
use Moose;

with 'HTML::FormHandler::Widget::Form::Simple';

# here to make it possible to combine the Blocks role with a role
# setting the render_list without an 'excludes'
sub has_render_list { }
sub build_render_list { return []; }

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
