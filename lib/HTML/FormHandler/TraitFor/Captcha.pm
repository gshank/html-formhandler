package HTML::FormHandler::TraitFor::Captcha;

use HTML::FormHandler::Moose::Role;
use GD::SecurityImage;
use HTTP::Date;

requires('ctx');

has_field 'captcha' => ( type => 'Captcha', label => 'Verification' );

=head1 NAME

HTML::FormHandler::TraitFor::Captcha - generate and validate captchas

=head1 SYNOPSIS

A role to use in a form to implement a captcha field.

   package MyApp::Form;
   use HTML::FormHandler::Moose;
   with 'HTML::FormHandler::TraitFor::Captcha';

or

   my $form = MyApp::Form->new( traits => ['HTML::FormHandler::TraitFor::Captcha'],
       ctx => $c );

Needs a context object set in the form's 'ctx' attribute which has a session
hashref in which to store a 'captcha' hashref, such as is provided by Catalyst
session plugin.

=head1 METHODS

=head2 get_captcha

Get a captcha stored in C<< $form->ctx->{session} >>

=cut

sub get_captcha {
    my $self = shift;
    return unless $self->ctx;
    my $captcha = $self->ctx->{session}->{captcha};
    return $captcha;
}

=head1 set_captcha

Set a captcha in C<< $self->ctx->{session} >>

=cut

sub set_captcha {
    my ( $self, $captcha ) = @_;
    return unless $self->ctx;
    $self->ctx->{session}->{captcha} = $captcha;
}

sub render_captcha {
    my ( $self, $field ) = @_;

    my $output = $self->_label($field);
    $output .= '<img src="' . $self->captcha_image_url . '"/>';
    $output .= '<input id="' . $field->id . '" name="';
    $output .= $field->name . '">';
    return $output;
}

sub captcha_image_url {
    my $self = shift;
    return '/captcha/test';
}

use namespace::autoclean;
1;
