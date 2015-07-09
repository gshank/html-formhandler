package HTML::FormHandler::Widget::Wrapper::TableInline;
# ABSTRACT: wrapper class for table layout that doesn't wrap compound fields
use strict;
use warnings;

use Moose::Role;
with 'HTML::FormHandler::Widget::Wrapper::Base';
use HTML::FormHandler::Render::Util ('process_attrs');

sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    return $rendered_widget if $self->has_flag('is_compound');

    my $output = "\n<tr" . process_attrs($self->wrapper_attributes($result)) . ">";
    if ( $self->do_label && length( $self->label ) > 0 ) {
        $output .= '<td>' . $self->do_render_label($result) . '</td>';
    }
    $output .= '<td>';
    $output .= $rendered_widget;
    $output .= qq{\n<span class="error_message">$_</span>} for $result->all_errors;
    $output .= "</td></tr>\n";

    return $output;
}

use namespace::autoclean;
1;
