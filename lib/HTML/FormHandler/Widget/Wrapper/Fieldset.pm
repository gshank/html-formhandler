package HTML::FormHandler::Widget::Wrapper::Fieldset;
# ABSTRACT: fieldset field wrapper

use Moose::Role;
use namespace::autoclean;

with 'HTML::FormHandler::Widget::Wrapper::Base';
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 NAME

HTML::FormHandler::Widget::Wrapper::Fieldset - fieldset field wrapper

=head1 SYNOPSIS

Wraps a single field in a fieldset.

=cut

sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $wattrs = process_attrs($self->wrapper_attributes);
    my $output .= qq{\n<fieldset$wattrs>};
    $output .= qq{\n<legend>} . $self->loc_label . '</legend>';

    $output .= "\n$rendered_widget";

    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_errors;
    $output .= "\n</fieldset>";

    return $output;
}

1;
