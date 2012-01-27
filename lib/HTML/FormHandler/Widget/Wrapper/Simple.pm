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

Supported 'widget_tags':

    wrapper_tag    -- the tag to use in the wrapper, default 'div'

    label_none     -- don't render a label
    label_tag      -- tag to use for label (default 'label')
    label_after    -- string to append to label, for example ': ' to append a colon

    form_wrapper   -- put a wrapper around main form
    form_wrapper_tag -- tag for form wrapper; default 'fieldset'

Are these necessary? Really, they should be specified at form level and propagated
to the appropriate fields.

    compound_wrapper -- put a wrapper around compound fields
    repeatable_wrapper
    contains_wrapper

=cut


sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $do_compound_wrapper = ( $self->has_flag('is_repeatable') && $self->get_tag('repeatable_wrapper') ) ||
                              ( $self->has_flag('is_contains') && $self->get_tag('contains_wrapper') )  ||
                              ( $self->has_flag('is_compound') && $self->get_tag('compound_wrapper') );
    return $rendered_widget if ( $self->has_flag('is_compound') && ! $do_compound_wrapper );
    my $output = "\n";
    my $wrapper_tag = $self->get_tag('wrapper_tag') || '';
    my $do_wrapper_tag = ! $self->tag_exists('wrapper_tag') || ( $self->tag_exists('wrapper_tag') && $self->get_tag('wrapper_tag') );
    if( $do_wrapper_tag ) {
        $wrapper_tag ||= $self->has_flag('is_repeatable') ? 'fieldset' : 'div';
        my $attrs = process_attrs( $self->wrapper_attributes($result) );
        $output .= qq{<$wrapper_tag$attrs>};
    }
    if( $wrapper_tag eq 'fieldset' ) {
        $output .= '<legend>' . $self->loc_label . '</legend>';
    }
    elsif ( ! $self->get_tag('label_none') && !$self->has_flag('no_render_label') && length( $self->label ) > 0 ) {
        $output .= $self->render_label;
    }
    $output .= $rendered_widget;
    my $after_element = $self->get_tag('after_element');
    $output .= $after_element if $after_element;
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_errors;
    $output .= "\n</$wrapper_tag>" if $do_wrapper_tag;
    return "$output";
}

1;
