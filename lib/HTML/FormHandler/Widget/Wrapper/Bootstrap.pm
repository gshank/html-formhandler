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

=cut


sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    return $rendered_widget if $self->tag_exists('wrapper') && ! $self->get_tag('wrapper');
    return $rendered_widget if ( $self->has_flag('is_compound') && ! $self->get_tag('wrapper') );

    my $output = "\n";
    # is this a control group or a form action?
    my $form_actions = 1 if ( $self->name eq 'form_actions' || $self->type_attr eq 'submit'
        || $self->type_attr eq 'reset' );
    # create attribute string for wrapper
    my $attr = $self->wrapper_attributes($result);
    my $div_class = $form_actions ? "form-actions" : "control-group";
    unshift @{$attr->{class}}, $div_class;
    my $attr_str = process_attrs( $attr );
    # wrapper is always a div
    $output .= qq{<div$attr_str>};
    if ( ! $self->get_tag('label_none') && $self->render_label && length( $self->label ) > 0 ) {
        my $label = $self->html_filter($self->loc_label);
        $output .= qq{<label class="control-label" for="} . $self->id . qq{">$label</label>};
    }
    $output .=  $self->get_tag('before_element');
    # the controls div for ... controls
    $output .= '<div class="controls">' unless $form_actions;
    # do extra wrappers for checkbox and radio
    if ( $self->type_attr eq 'checkbox' ) {
        $output .= $self->wrap_checkbox($rendered_widget);
    }
    elsif ( $self->type_attr eq 'radio' ) {
        $output .= $self->wrap_radio($rendered_widget);
    }
    else {
        $output .= $rendered_widget;
    }
    # various 'help-inline' bits: errors, warnings
    $output .= qq{\n<span class="help-inline">$_</span>}
        for $result->all_errors;
    $output .= qq{\n<span class="help-inline">$_</span>} for $result->all_warnings;
    # extra after element stuff
    $output .= $self->get_tag('after_element');
    # close 'control' div
    $output .= '</div>' unless $form_actions;
    # close wrapper
    $output .= "\n</div>";
    return "$output";
}

sub wrap_checkbox {
    my ( $self, $rendered_widget ) = @_;

    # special extra wrapped label for checkbox, including checkbox class
    my $output .= '<label class="checkbox">' if $self->type_attr eq 'checkbox';
    # the actual rendered input element
    $output .= $rendered_widget;
    # end special checkbox label
    my $label2 = $self->get_tag('option_label');
    $label2 ||= $self->label;
    $label2 = $self->html_filter($self->_localize($label2));
    $output .= "$label2</label>";
    return $output;
}
sub wrap_radio {
    my ( $self, $rendered_widget ) = @_;
    # stub
    return $rendered_widget;
}

1;
