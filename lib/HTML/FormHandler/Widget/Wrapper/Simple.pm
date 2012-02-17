package HTML::FormHandler::Widget::Wrapper::Simple;
# ABSTRACT: simple field wrapper

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

with 'HTML::FormHandler::Widget::Wrapper::Base';

=head1 SYNOPSIS

This is the default wrapper role. It will be installed if
no other wrapper is specified and widget_wrapper is not set to
'none'.

Relevant field flags:

   render_wrapper
   render_label

If 'render_label' is set and not 'render_wrapper', only the label plus
the form element will be rendered.

Supported 'tags':

    wrapper_tag    -- the tag to use in the wrapper, default 'div'

    label_tag      -- tag to use for label (default 'label')
    label_after    -- string to append to label, for example ': ' to append a colon

    before_element -- string that goes right before the element
    after_element  -- string that goes right after the element

    error_class    -- class for error messages (default 'error_message')
    warning_class  -- class for warning messages (default 'warning_message' )


=cut


sub wrap_field {
    my ( $self, $result, $rendered_widget, $wrap_label ) = @_;

    return "\n$rendered_widget" if ( ! $self->render_wrapper && ! $self->render_label );

    # each field starts with a newline
    my $output = "\n";
    # get wrapper tag if set
    my $label_tag;
    my $wrapper_tag;
    if( $self->render_wrapper ) {
        $wrapper_tag = $self->get_tag('wrapper_tag');
        # default wrapper tags
        $wrapper_tag ||= $self->has_flag('is_repeatable') ? 'fieldset' : 'div';
        # get attribute string
        my $attrs = process_attrs( $self->wrapper_attributes($result) );
        # write wrapper tag
        $output .= qq{\n<$wrapper_tag$attrs>};
        $label_tag = 'legend' if $wrapper_tag eq 'fieldset';
    }
    # write label; special processing (wrap_label) for checkboxes
    if( $wrap_label ) {
        $rendered_widget = $self->do_render_wrapped_label($result, $rendered_widget, $label_tag);
    }
    elsif( $self->render_label ) {
        $output .= "\n" . $self->do_render_label($result, $label_tag );
    }
    # append 'before_element'
    $output .= $self->get_tag('before_element');
    # the input element itself
    $output .= "\n$rendered_widget";
    # the 'after_element'
    $output .= $self->get_tag('after_element');
    # the error messages
    my $error_class = $self->get_tag('error_class') || 'error_message';
    $output .= qq{\n<span class="$error_class">$_</span>}
        for $result->all_errors;
    # warnings (incompletely implemented - only on field itself)
    my $warning_class = $self->get_tag('warning_class') || 'warning_message';
    $output .= qq{\n<span class="warning_message">$_</span>}
        for $result->all_warnings;
    if( $self->render_wrapper ) {
        $output .= "\n</$wrapper_tag>";
    }
    return "$output";
}


1;
