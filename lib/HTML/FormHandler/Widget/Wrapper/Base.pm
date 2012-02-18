package HTML::FormHandler::Widget::Wrapper::Base;
# ABSTRACT: common methods for widget wrappers

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');

sub do_render_label {
    my ( $self, $result, $label_tag ) = @_;

    my $no_for = $self->type_attr eq 'checkbox' && !$self->get_tag('checkbox_unwrapped') && !$self->get_tag('checkbox_single_label');
    $label_tag ||= $self->get_tag('label_tag') || 'label';
    my $attrs = process_attrs($self->label_attributes($result));
    my $label = $self->html_filter($self->loc_label);
    $label .= $self->get_tag('label_after') if $label_tag ne 'legend';
    my $id = $self->id;
    my $for = $label_tag eq 'label' && !$no_for ? qq{ for="$id"} : '';
    return qq{<$label_tag$attrs$for>$label</$label_tag>};
}

sub do_render_wrapped_label {
    my ( $self, $result, $rendered_widget, $label_tag ) = @_;

    $label_tag ||= $self->get_tag('label_tag') || 'label';
    my $attrs = process_attrs($self->label_attributes($result));
    my $label = $self->html_filter($self->loc_label);
    $label .= $self->get_tag('label_after') if $label_tag ne 'legend';
    my $id = $self->id;
    my $for = $label_tag eq 'label' ? qq{ for="$id"} : '';
    if( $self->get_tag('label_left') ) {
        return qq{<$label_tag$attrs$for>$label$rendered_widget</$label_tag>};
    }
    return qq{<$label_tag$attrs$for>$rendered_widget$label</$label_tag>};
}

# for compatibility with older code
sub render_label {
    my $self = shift;
    my $attrs = process_attrs($self->label_attributes);
    my $label = $self->html_filter($self->loc_label);
    $label .= ": " unless $self->get_tag('label_no_colon');
    return qq{<label$attrs for="} . $self->id . qq{">$label</label>};
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
