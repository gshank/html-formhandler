package HTML::FormHandler::Widget::Wrapper::Bootstrap;
# ABSTRACT: Twitter Bootstrap 2.0 field wrapper

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

with 'HTML::FormHandler::Widget::Wrapper::Base';

=head1 SYNOPSIS

Wrapper to implement Bootstrap 2.0 style form element rendering. This wrapper
does some very specific Bootstrap things, like wrap the form elements
in divs with non-changeable classes. It is not as flexible as the
'Simple' wrapper, but means that you don't have to specify those classes
in your form code.

It wraps form elements with 'control-group' divs, and form 'actions' with
'form-actions' divs. It adds special additional wrappers for checkboxes and radio
buttons, with wrapped labels.

=head1 DESCRIPTION

Tags supported:

   label_no_filter -- don't html filter the label
   label_after -- useful for putting a colon, or other trailing formatting
   before_element -- insert tag before input, outside element's control div
   before_element_inside_div -- insert tag before input element, inside control div
   input_prepend -- for Bootstrap 'input-prepend' class
   input_append -- for Bootstrap 'input-append' class
   input_append_button -- 'input-append' with button instead of span
   no_errors -- don't append error to field rendering
   after_element -- insert tag after input element

=cut


sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $output;
    # is this a control group or a form action?
    my $form_actions = 1 if ( $self->name eq 'form_actions' || $self->type_attr eq 'submit'
        || $self->type_attr eq 'reset' );
    # create attribute string for wrapper
    my $attr = $self->wrapper_attributes($result);
    # no 'control-group' class for Hidden fields, 'form-actions' for submit/reset
    my $div_class = $self->type eq 'Hidden' ? undef : $form_actions ? "form-actions" : "control-group";
    unshift @{$attr->{class}}, $div_class if $div_class;
    my $attr_str = process_attrs( $attr );
    # wrapper is always a div
    if ( $self->do_wrapper ) {
        $output .= $self->get_tag('before_wrapper');
        $output .= qq{\n<div$attr_str>};
    }
    # render the label
    $output .= "\n" . $self->do_render_label($result, undef, ['control-label'] )
        if $self->do_label;
    $output .=  $self->get_tag('before_element');
    # the controls div for ... controls
    $output .= qq{\n<div class="controls">}
        unless $form_actions || !$self->do_wrapper;
    # yet another tag
    $output .= $self->get_tag('before_element_inside_div');
    # handle input-prepend and input-append
    if( $self->get_tag('input_prepend') || $self->get_tag('input_append') ||
            $self->get_tag('input_append_button') ) {
        $rendered_widget = $self->do_prepend_append($rendered_widget);
    }
    elsif( lc $self->widget eq 'checkbox' ) {
        $rendered_widget = $self->wrap_checkbox($result, $rendered_widget)
    }

    $output .= "\n$rendered_widget";
    # various 'help-inline' bits: errors, warnings
    unless( $self->get_tag('no_errors') ) {
        $output .= qq{\n<span class="help-inline">$_</span>}
            for $result->all_errors;
        $output .= qq{\n<span class="help-inline">$_</span>} for $result->all_warnings;
    }
    # extra after element stuff
    $output .= $self->get_tag('after_element');
    # close 'control' div
    $output .= '</div>' unless $form_actions || !$self->do_wrapper;
    # close wrapper
    if ( $self->do_wrapper ) {
        $output .= "\n</div>";
        $output .= $self->get_tag('after_wrapper');
    }
    return "$output";
}

sub do_prepend_append {
    my ( $self, $rendered_widget ) = @_;

    my @class;
    if( my $ip_tag = $self->get_tag('input_prepend' ) ) {
        $rendered_widget = qq{<span class="add-on">$ip_tag</span>$rendered_widget};
        push @class, 'input-prepend';
    }
    if ( my $ia_tag = $self->get_tag('input_append' ) ) {
        $rendered_widget = qq{$rendered_widget<span class="add-on">$ia_tag</span>};
        push @class, 'input-append';
    }
    if ( my $iab_tag = $self->get_tag('input_append_button') ) {
        my @buttons = ref $iab_tag eq 'ARRAY' ? @$iab_tag : ($iab_tag);
        foreach my $btn ( @buttons ) {
            $rendered_widget = qq{$rendered_widget<button type="button" class="btn">$btn</button>};
        }
        push @class, 'input-append';
    }
    my $attr = process_attrs( { class => \@class } );
    $rendered_widget =
qq{<div$attr>
  $rendered_widget
</div>};
    return $rendered_widget;
}

1;
