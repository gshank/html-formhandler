package HTML::FormHandler::Widget::Theme::BootstrapHoriz;
# ABSTRACT: sample bootstrap theme

=head1 SYNOPSIS

Sample Bootstrap theme role. Apply to your subclass of HTML::FormHandler

=cut

use Moose::Role;

sub before_build {
    my $self = shift;
    $self->set_widget_wrapper('Bootstrap');
}

sub build_form_element_class { ['form-horizontal'] }

sub render_form_messages {
    my ( $self, $result ) = @_;

    my $output = '';
    if ( $result->has_form_errors ) {
        $output = qq{\n<div class="alert alert-error">};
        $output .= qq{\n<span class="error_message">$_</span>}
            for $result->all_form_errors;
        $output .= "\n</div>";
    }
    elsif ( $result->validated && ! $result->has_form_errors ) {
        $output = qq{\n<div class="alert alert-success">};
        $output .= qq{\n<span>Your form was successfully submitted</span>};
        $output .= "\n</div>";
    }
    return $output;
}


1;
