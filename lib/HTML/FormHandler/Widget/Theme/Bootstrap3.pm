package HTML::FormHandler::Widget::Theme::Bootstrap3;
# ABSTRACT: sample bootstrap theme

=head1 SYNOPSIS

Also see L<HTML::FormHandler::Manual::Rendering>.

Sample Bootstrap theme role. Can be applied to your subclass of HTML::FormHandler.
Sets the widget wrapper to 'Bootstrap3' and renders form messages using Bootstrap
formatting and classes.

There is an example app using Bootstrap at http://github.com:gshank/formhandler-example.

This is a lightweight example of what you could do in your own custom
Bootstrap theme. The heavy lifting is done by the Bootstrap wrapper,
L<HTML::FormHandler::Widget::Wrapper::Bootstrap>,
which you can use by itself in your form with:

    has '+widget_wrapper' => ( default => 'Bootstrap' );

It also uses L<HTML::FormHandler::Widget::Theme::BootstrapFormMessages>
to render the form messages in a Bootstrap style:

   <div class="alert alert-error">
       <span class="error_message">....</span>
   </div>

By default this does 'form-horizontal' with 'build_form_element_class'.
Implement your own sub to use 'form-vertical':

   sub build_form_element_class { ['form-vertical'] }


=cut

use Moose::Role;
with 'HTML::FormHandler::Widget::Theme::BootstrapFormMessages';

after 'before_build' => sub {
    my $self = shift;
    $self->set_widget_wrapper('Bootstrap3')
       if $self->widget_wrapper eq 'Simple';
};

sub build_form_element_class { ['form-horizontal'] }

sub form_messages_alert_error_class { 'alert-danger' }

1;
