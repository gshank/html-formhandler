package HTML::FormHandler::Widget::Wrapper::Base;
# ABSTRACT: commong methods for widget wrappers

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');

sub do_render_label {
    my ( $self, $result ) = @_;
    my $attrs = process_attrs($self->label_attributes($result));
    my $label = $self->html_filter($self->loc_label);
    $label .= $self->get_tag('label_after')
        if( $self->tag_exists('label_after') );
    my $label_tag = $self->tag_exists('label_tag') ? $self->get_tag('label_tag') : 'label';
    return qq{<$label_tag$attrs for="} . $self->id . qq{">$label</$label_tag>};
}

# this is not actually used any more, but is left here for compatibility
# with user created widgets
sub render_class {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    return process_attrs($self->wrapper_attributes($result));
}

use namespace::autoclean;
1;
