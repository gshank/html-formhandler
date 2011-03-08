package HTML::FormHandler::Widget::Wrapper::TableInline;
# ABSTRACT: wrapper class for table layout that doesn't wrap compound fields

use Moose::Role;
with 'HTML::FormHandler::Widget::Wrapper::Base';

sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    return $rendered_widget if $self->has_flag('is_compound');

    my $class  = $self->render_class($result);
    my $output = "\n<tr$class>";
    if ( !$self->has_flag('no_render_label') && length( $self->label ) > 0 ) {
        $output .= '<td>' . $self->render_label . '</td>';
    }
    $output .= '<td>';
    $output .= $rendered_widget;
    $output .= qq{\n<span class="error_message">$_</span>} for $result->all_errors;
    $output .= "</td></tr>\n";

    return $output;
}

use namespace::autoclean;
1;
