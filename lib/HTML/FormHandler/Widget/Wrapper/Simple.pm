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
    $do_wrapper_tag = 1 if $self->has_flag('is_contains');
    if( $do_wrapper_tag ) {
        $wrapper_tag ||= $self->has_flag('is_repeatable') ? 'fieldset' : 'div';
        my $attrs = process_attrs( $self->wrapper_attributes($result) );
        $output .= qq{<$wrapper_tag$attrs>};
    }
    my $do_label = ( ! $self->get_tag('label_none') && $self->render_label );
    if( $wrapper_tag eq 'fieldset' ) {
        $output .= '<legend>' . $self->loc_label . '</legend>';
        $do_label = 0;
    }
    if( $do_label && ($self->type_attr ne 'checkbox' ||
            $self->get_tag('checkbox_double_label') || $self->get_tag('checkbox_unwrapped'))) {
        $output .= $self->do_render_label;
    }
    if( $self->type_attr eq 'checkbox' && ! $self->get_tag('checkbox_unwrapped') ) {
        my $before_element = $self->get_tag('before_element');
        $output .= $before_element if $before_element;
        $output .= $self->render_checkbox( $rendered_widget );
    }
    else {
        my $before_element = $self->get_tag('before_element');
        $output .= $before_element if $before_element;
        $output .= $rendered_widget;
    }
    my $after_element = $self->get_tag('after_element');
    $output .= $after_element if $after_element;
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_errors;
    $output .= "\n</$wrapper_tag>" if $do_wrapper_tag;
    return "$output";
}

sub render_checkbox {
    my ( $self, $rendered_widget ) = @_;

    my $lattr = process_attrs($self->label_attributes);
    my $id = $self->id;
    my $label = $self->get_tag('checkbox_double_label') ?
       ( $self->get_tag('comment') || $self->label ) :
       $self->label;
    $label = $self->html_filter($self->_localize($label));
    my $output = qq{<label$lattr for="$id">};
    my $label_left = $self->get_tag('label_left');
    $output .= $label if $label_left;
    $output .= $rendered_widget;
    $output .= $label if ! $label_left;
    $output .= "</label>";
}

1;
