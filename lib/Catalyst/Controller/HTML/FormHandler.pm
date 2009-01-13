package Catalyst::Controller::HTML::FormHandler;

use Moose;
use base 'Catalyst::Controller';
with 'Catalyst::Controller::Role::HTML::FormHandler';

our $VERSION = '0.01';

=head1 NAME

Catalyst::Controller::HTML::FormHandler - a base controller for Catalyst

=head1 SYNOPSIS

A base controller class for Catalyst controllers to use
HTML::FormHandler forms

=head1 DESCRIPTION

For usage see L<Catalyst::Controller::Role::HTML::FormHandler>
This class only adds an 'end' routine calling L<HTML::FillInForm>
to fill in the form values

=head1 end

Calls L<HTML::FillInForm> to render the form.

If you have a custom "end" routine in your subclassed controllers
and want to use FillInForm to fill in your forms, you can use
this as a sample of how to handle FillInForm in your custom 'end'.

=back

=cut

sub end : Private
{

   my ( $self, $ctx ) = ( shift, shift );

   my $form = $ctx->stash->{form};
   $ctx->forward('render') unless $ctx->res->output;
   if ($form)
   {
      if ( HTML::FillInForm->require )
      {
         $ctx->response->body(
            HTML::FillInForm->new->fill(
               scalarref => \$ctx->response->{body},
               fdat      => $form->fif,
            )
         );
      }
   }
}

sub render : ActionClass('RenderView') { }

=head1 AUTHOR

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
