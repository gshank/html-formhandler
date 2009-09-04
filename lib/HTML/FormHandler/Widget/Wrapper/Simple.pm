package HTML::FormHandler::Widget::Wrapper::Simple;

use Moose::Role;
with 'HTML::FormHandler::Widget::Wrapper::Base';

sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $start_tag = $self->get_tag('wrapper_start') || '<div<%class%>>';
    my $class  = $self->render_class($result);
    $start_tag =~ s/<%class%>/$class/g;
    my $output = "\n" . $start_tag; 
    if ( $self->has_flag('is_compound') ) {
        $output .= '<fieldset class="' . $self->html_name . '">';
        $output .= '<legend>' . $self->label . '</legend>';
    }
    elsif ( !$self->has_flag('no_render_label') && $self->label ) {
        $output .= $self->render_label;
    }
    $output .= $rendered_widget;
    $output .= qq{\n<span class="error_message">$_</span>} for $result->all_errors;
    if ( $self->has_flag('is_compound') ) {
        $output .= '</fieldset>';
    }
    my $end_tag = $self->get_tag('wrapper_end') || '</div>';
    $output .= $end_tag . "\n";
    return $output;
}

no Moose::Role;
1;
