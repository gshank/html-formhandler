package HTML::FormHandler::Widget::Wrapper::Base;
# ABSTRACT: common methods for widget wrappers

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 NAME

HTML::FormHandler::Widget::Wrapper::Base

=head1 DESCRIPTION

Provides several common methods for wrapper widgets, including
'do_render_label' and 'wrap_checkbox'.

Implements the checkbox 'option_wrapper' rendering:

    b3_label_left
    b3_label_right
    b3_label_left_inline
    label_left
    label_right
    no_wrapped_label

=cut

sub do_render_label {
    my ( $self, $result, $label_tag, $class ) = @_;

    $label_tag ||= $self->get_tag('label_tag') || 'label';
    my $attr = $self->label_attributes( $result );
    push @{ $attr->{class} }, @$class if $class;
    my $attrs = process_attrs($attr);
    my $label;
    if( $self->does_wrap_label ) {
        $label = $self->wrap_label( $self->label );
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
    my ( $self, $result, $rendered_widget, $default_wrapper ) = @_;

    my $option_wrapper = $self->option_wrapper || $default_wrapper;
    if ( $option_wrapper && $option_wrapper ne 'standard' &&
         $option_wrapper ne 'label' ) {
        unless ( $self->can($option_wrapper) ) {
            die "HFH: no option_wrapper method '$option_wrapper'";
        }
        return $self->$option_wrapper($result, $rendered_widget);
    }
    else {
        return $self->standard_wrap_checkbox($result, $rendered_widget);
    }

}

sub standard_wrap_checkbox {
    my ( $self, $result, $rendered_widget ) = @_;

    return $rendered_widget
        if( $self->get_tag('no_wrapped_label' ) );

    my $label = $self->get_checkbox_label;
    my $id = $self->id;
    my $for = qq{ for="$id"};

    # use "simple" label attributes for inner label
    my @label_class = ('checkbox');
    push @label_class, 'inline' if $self->get_tag('inline');
    my $lattrs = process_attrs( { class => \@label_class } );

    # return wrapped checkbox, either on left or right
    my $output = '';
    if ( $self->get_tag('label_left') ) {
        $output = qq{<label$lattrs$for>\n$label\n$rendered_widget</label>};
    }
    else {
        $output = qq{<label$lattrs$for>$rendered_widget\n$label\n</label>};
    }
    if ( $self->get_tag('checkbox_element_wrapper') ) {
        $output = qq{<div class="checkbox">$output</div>};
    }
    return $output;
}

sub get_checkbox_label {
    my $self = shift;

    my $label =  $self->option_label || '';
    if( $label eq '' && ! $self->do_label ) {
        $label = $self->get_tag('label_no_filter') ? $self->loc_label : $self->html_filter($self->loc_label);
    }
    elsif( $label ne '' ) {
        $label = $self->get_tag('label_no_filter') ? $self->_localize($label) : $self->html_filter($self->_localize($label));
    }
    return $label;
}

sub b3_label_left {
    my ( $self, $result, $rendered_widget ) = @_;

    my $label = $self->get_checkbox_label;
    my $id = $self->id;
    my $output = qq{<div class="checkbox">};
    $output .= qq{<label for="$id">\n$label\n$rendered_widget</label>};
    $output .= qq{</div>};
    return $output;
}

sub b3_label_left_inline {
    my ( $self, $result, $rendered_widget ) = @_;

    my $label = $self->get_checkbox_label;
    my $id = $self->id;
    my $output = qq{<label class="checkbox-inline" for="$id">\n$label\n$rendered_widget</label>};
    return $output;
}

sub b3_label_right {
    my ( $self, $result, $rendered_widget ) = @_;

    my $label = $self->get_checkbox_label;
    my $id = $self->id;
    my $output = qq{<div class="checkbox">};
    $output .= qq{<label for="$id">$rendered_widget\n$label\n</label>};
    $output .= qq{</div>};
    return $output;
}

sub label_left {
    my ( $self, $result, $rendered_widget ) = @_;

    my $label = $self->get_checkbox_label;
    my $id = $self->id;
    my $output = qq{<label class="checkbox" for="$id">\n$label\n$rendered_widget</label>};
    return $output;
}

sub label_right {
    my ( $self, $result, $rendered_widget ) = @_;

    my $label = $self->get_checkbox_label;
    my $id = $self->id;
    my $output = qq{<label class="checkbox" for="$id">$rendered_widget\n$label\n</label>};
    return $output;
}

sub no_wrapped_label {
    my ( $self, $result, $rendered_widget ) = @_;
    return $rendered_widget;
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
