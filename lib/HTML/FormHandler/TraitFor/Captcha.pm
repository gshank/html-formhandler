package HTML::FormHandler::TraitFor::Captcha;
# ABSTRACT: generate and validate captchas
use strict;
use warnings;

use HTML::FormHandler::Moose::Role;
use GD::SecurityImage;
use HTTP::Date;

requires('ctx');

has_field 'captcha' => ( type => 'Captcha', label => 'Verification' );

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
    my $captcha;
    $captcha = $self->ctx->session->{captcha};
    return $captcha;
}

=head1 set_captcha

Set a captcha in C<< $self->ctx->{session} >>

=cut

sub set_captcha {
    my ( $self, $captcha ) = @_;
    return unless $self->ctx;
    $self->ctx->session( captcha => $captcha );
}

=head2 captcha_image_url

Default is '/captcha/image'. Override in a form to change.

   sub captcha_image_url { '/my/image/url/' }

Example of a Catalyst action to handle the image:

    sub image : Local {
        my ( $self, $c ) = @_;
        my $captcha = $c->session->{captcha};
        $c->response->body($captcha->{image});
        $c->response->content_type('image/'. $captcha->{type});
        $c->res->headers->expires( time() );
        $c->res->headers->header( 'Last-Modified' => HTTP::Date::time2str );
        $c->res->headers->header( 'Pragma'        => 'no-cache' );
        $c->res->headers->header( 'Cache-Control' => 'no-cache' );
    }

=cut

sub captcha_image_url {
    return '/captcha/image';
}

use namespace::autoclean;
1;
