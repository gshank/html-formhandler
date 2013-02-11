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

   do_wrapper
   do_label

If 'do_label' is set and not 'do_wrapper', only the label plus
the form element will be rendered.

Supported 'tags', all set via the 'tags' hashref on the field:

    wrapper_tag    -- the tag to use in the wrapper, default 'div'

    label_tag      -- tag to use for label (default 'label')
    label_after    -- string to append to label, for example ': ' to append a colon

    before_element -- string that goes right before the element
    after_element  -- string that goes right after the element

    no_errors      -- don't issue error messages on the field
    error_class    -- class for error messages (default 'error_message')
    warning_class  -- class for warning messages (default 'warning_message' )

    no_wrapped_label -- for checkboxes. Don't provide an inner wrapped label
                        (from Base wrapper)

Example:

    has_field 'foo' => ( tags => { wrapper_tag => 'span', no_errors => 1 } );

=cut


sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $output;
    # get wrapper tag if set
    my $label_tag = $self->label_tag || '';
    my $wrapper_tag;
    if( $self->do_wrapper ) {
        $output .= $self->get_tag('before_wrapper');
        $wrapper_tag = $self->get_tag('wrapper_tag');
        # default wrapper tags
        $wrapper_tag ||= $self->has_flag('is_repeatable') ? 'fieldset' : 'div';
        # get attribute string
        my $attrs = process_attrs( $self->wrapper_attributes($result) );
        # write wrapper tag
        $output .= qq{\n<$wrapper_tag$attrs>};
        $label_tag = 'legend' if $wrapper_tag eq 'fieldset';
    }
    # write label; special processing for checkboxes
    $rendered_widget = $self->wrap_checkbox($result, $rendered_widget, $label_tag)
        if ( lc $self->widget eq 'checkbox' );
    $output .= "\n" . $self->do_render_label($result, $label_tag )
        if $self->do_label;
    # append 'before_element'
    $output .= $self->get_tag('before_element');
    # start control div
    $output .= qq{\n<div class="controls">} if $self->get_tag('controls_div');
    # the input element itself
    $output .= "\n$rendered_widget";
    # end control div
    $output .= "\n</div>" if $self->get_tag('controls_div');
    # the 'after_element'
    $output .= $self->get_tag('after_element');
    # the error messages
    unless( $self->get_tag('no_errors') ) {
        my $error_class = $self->get_tag('error_class') || 'error_message';
        $output .= qq{\n<span class="$error_class">$_</span>}
            for $result->all_errors;
        # warnings (incompletely implemented - only on field itself)
        my $warning_class = $self->get_tag('warning_class') || 'warning_message';
        $output .= qq{\n<span class="warning_message">$_</span>}
            for $result->all_warnings;
    }
    if( $self->do_wrapper ) {
        $output .= "\n</$wrapper_tag>";
        $output .= $self->get_tag('after_wrapper');
    }
    return "$output";
}


1;
