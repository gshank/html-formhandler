package HTML::FormHandler::Widget::Wrapper::Div;

use Moose::Role;
with 'HTML::FormHandler::Widget::Wrapper::Base';

sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $class  = $self->render_class($result);
    my $output = qq{\n<div$class>};
    if ( $self->has_flag('is_compound') ) {
        $output .= '<fieldset class="' . $self->html_name . '">';
        $output .= '<legend>' . $self->label . '</legend>';
    }
    elsif ( !$self->has_flag('no_render_label') && $self->label ) {
        $output .= $self->render_label;
    }
    $output .= $rendered_widget;
    $output .= qq{\n<span class="error_message">$_</span>} for $result->errors;
    if ( $self->has_flag('is_compound') ) {
        $output .= '</fieldset>';
    }
    $output .= "</div>\n";
    return $output;
}

no Moose::Role;
1;
