package HTML::FormHandler::Widget::Wrapper::Bootstrap;
# ABSTRACT: simple field wrapper

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

with 'HTML::FormHandler::Widget::Wrapper::Base';

=head1 SYNOPSIS

Wrapper to implement Bootstrap style form element rendering. This wrapper
does some very specific Bootstrap things, like wrap the form elements
is divs with non-changeable classes. It is not as flexible as the
'Simple' wrapper, but means that you don't have to specify those classes
in your form code.

=cut


sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $do_compound_wrapper = ( $self->has_flag('is_repeatable') && $self->get_tag('repeatable_wrapper') ) ||
                              ( $self->has_flag('is_contains') && $self->get_tag('contains_wrapper') )  ||
                              ( $self->has_flag('is_compound') && $self->get_tag('compound_wrapper') );
    return $rendered_widget if ( $self->has_flag('is_compound') && ! $do_compound_wrapper );
    my $output = "\n";

    $output .= '<div class="control-group">';
    if ( ! $self->get_tag('label_none') && $self->render_label && length( $self->label ) > 0 ) {
        my $label = $self->html_filter($self->loc_label);
        $output .= qq{<label class="control-label" for="} . $self->id . qq{">$label</label>};
    }
    my $before_element = $self->get_tag('before_element');
    $output .= '<div class="controls">';
    $output .= '<label class="checkbox">' if $self->type_attr eq 'checkbox';
    $output .= $rendered_widget;
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_errors;
    $output .= $self->get_tag('after_element') if $self->tag_exists('after_element');
    $output .= '</label>' if $self->type_attr eq 'checkbox';
    $output .= '</div>';
    $output .= "\n</div>";
    return "$output";
}

1;
