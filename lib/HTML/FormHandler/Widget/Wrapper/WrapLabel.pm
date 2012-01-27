package HTML::FormHandler::Widget::Wrapper::WrapLabel;
# ABSTRACT: simple field wrapper

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

This wrapper wraps a label around a checkbox.

=cut


sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $output = "\n";
    my $wrapper_tag = $self->get_tag('wrapper_tag') || 'div';
    my $do_wrapper_tag = ! $self->tag_exists('wrapper_tag') || ( $self->tag_exists('wrapper_tag') && $self->get_tag('wrapper_tag') );
    my $do_label = ( ! $self->get_tag('label_none') && !$self->has_flag('no_render_label') && length( $self->label ) > 0 );
    if( $do_wrapper_tag ) {
        my $attrs = process_attrs( $self->wrapper_attributes($result) );
        $output .= qq{<$wrapper_tag$attrs>};
    }
    if ( $do_label ) {
        my $lattrs = process_attrs($self->label_attributes);
        my $label_tag = $self->tag_exists('label_tag') ? $self->get_tag('label_tag') : 'label';
        $output .= qq{<$label_tag$lattrs for="} . $self->id . qq{">};
    }
    $output .= $rendered_widget;
    if( $do_label ) {
        my $label = $self->html_filter($self->loc_label);
        $label .= $self->get_tag('label_after')
            if( $self->tag_exists('label_after') );
        $output .= $label;
        my $label_tag = $self->tag_exists('label_tag') ? $self->get_tag('label_tag') : 'label';
        $output .= "</$label_tag>";
    }
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_errors;
    $output .= "\n</$wrapper_tag>" if $do_wrapper_tag;
    return "$output";
}

1;
