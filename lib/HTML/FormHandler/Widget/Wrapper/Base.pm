package HTML::FormHandler::Widget::Wrapper::Base;
# ABSTRACT: common methods for widget wrappers

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');

sub do_render_label {
    my ( $self, $result, $label_tag ) = @_;

    $label_tag ||= $self->get_tag('label_tag') || 'label';
    my $attrs = process_attrs($self->label_attributes($result));
    my $label;
    if( $self->does_wrap_label ) {
        $label = $self->wrap_label;
    }
    else {
        $label = $self->get_tag('label_no_filter') ? $self->loc_label : $self->html_filter($self->loc_label);
    }
    $label .= $self->get_tag('label_after') if $label_tag ne 'legend';
    my $id = $self->id;
    my $for = $label_tag eq 'label' ? qq{ for="$id"} : '';
    return qq{<$label_tag$attrs$for>$label</$label_tag>};
}

sub wrap_checkbox {
    my ( $self, $result, $rendered_widget ) = @_;

    return $rendered_widget
        if( $self->get_tag('no_wrapped_label' ) );

    my $label =  $self->option_label || '';
    if( $label eq '' && ! $self->do_label ) {
        $label = $self->html_filter($self->loc_label);
    }
    elsif( $label ne '' ) {
        $label = $self->html_filter($self->_localize($label));
    }
    my $id = $self->id;
    my $for = qq{ for="$id"};

    # use "simple" label attributes for inner label
    my @label_class = ('checkbox');
    push @label_class, 'inline' if $self->get_tag('inline');
    my $lattrs = process_attrs( { class => \@label_class } );

    # return wrapped checkbox, either on left or right
    return qq{<label$lattrs$for>\n$label\n$rendered_widget</label>}
        if( $self->get_tag('label_left') );
    return qq{<label$lattrs$for>$rendered_widget\n$label\n</label>};
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
