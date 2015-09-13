package HTML::FormHandler::Widget::Block::Bootstrap;
# ABSTRACT: block to format bare form element like bootstrap
use strict;
use warnings;
use Moose;
extends 'HTML::FormHandler::Widget::Block';

has 'after_controls' => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->add_class('control-group');
    $self->add_label_class('control-label');
    $self->label_tag('label');
}

sub render_from_list {
    my ( $self, $result ) = @_;
    $result ||= $self->form->result;
    my $output = $self->next::method($result);
    my $after_controls = $self->after_controls || '';
    return qq{<div class="controls">\n$output\n$after_controls\n</div>\n};
}

1;
