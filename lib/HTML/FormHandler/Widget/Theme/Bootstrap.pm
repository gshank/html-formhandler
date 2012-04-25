package HTML::FormHandler::Widget::Theme::Bootstrap;
# ABSTRACT: sample bootstrap theme

=head1 SYNOPSIS

Sample Bootstrap theme role. Apply to your subclass of HTML::FormHandler
Sets the widet wrapper to 'Bootstrap' and renders form messages using Bootstrap
formatting and classes.  Does 'form-horizontal' with 'build_form_element_class'.
Implement your own sub to use 'form-vertical':

   sub build_form_element_class { ['form-vertical'] }

Form error messages:

   <div class="alert alert-error">
       <span class="error_message">....</span>
   </div>


=cut

use Moose::Role;

after 'before_build' => sub {
    my $self = shift;
    $self->set_widget_wrapper('Bootstrap')
       if $self->widget_wrapper eq 'Simple';
};

sub build_form_element_class { ['form-horizontal'] }

sub render_form_messages {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = '';
    if ( $result->has_form_errors || $result->has_errors ) {
        $output = qq{\n<div class="alert alert-error">};
        my $msg = $self->error_message;
        $msg ||= 'There were errors in your form';
        $msg = $self->_localize($msg);
        $output .= qq{\n<span class="error_message">$msg</span>};
        $output .= qq{\n<span class="error_message">$_</span>}
            for $result->all_form_errors;
        $output .= "\n</div>";
    }
    elsif ( $result->validated ) {
        my $msg = $self->success_message;
        $msg ||= "Your form was successfully submitted";
        $msg = $self->_localize($msg);
        $output = qq{\n<div class="alert alert-success">};
        $output .= qq{\n<span>$msg</span>};
        $output .= "\n</div>";
    }
    return $output;
}

1;
