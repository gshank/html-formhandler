package HTML::FormHandler::Widget::Wrapper::Fieldset;

use Moose::Role;
use namespace::autoclean;

with 'HTML::FormHandler::Widget::Wrapper::Base';

=head1 NAME

HTML::FormHandler::Widget::Wrapper::Fieldset

=head1 SYNOPSIS

Wraps a single field in a fieldset.
    
=cut

sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $output .= '<fieldset class="' . $self->html_name . '">';
    $output .= '<legend>' . $self->loc_label . '</legend>';

    $output .= $rendered_widget;

    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_errors;
    $output .= '</fieldset>';

    return "$output\n";
}

1;
