package Catalyst::Controller::Role::HTML::FormHandler;

use Moose::Role;
with 'Catalyst::Component::InstancePerContext';

use Carp;
use UNIVERSAL::require;

our $VERSION = '0.02';

=head1 NAME

Catalyst::Controller::Role::HTML::FormHandler - a Moose role for Catalyst controllers

=head1 SYNOPSIS

A Moose role for Catalyst controllers to use
HTML::FormHandler forms.

=head1 DESCRIPTION

In a Catalyst controller:

   package MyApp::Controller::Book;

   use base 'Catalyst::Controller';
   with 'Catalyst::Controller::Role::HTML::FormHandler';

   __PACKAGE__->config( model_name => 'DB', form_name_space => 'MyApp::Form');

   sub edit : Local {
      my ( $self, $c ) = @_;
      $c->forward('do_form');
   }

   sub form : Private {
       my ( $self, $c, $id ) = @_;

      # Name template, or allow default 'book/add.tt'
      $self->ctx->stash->{template} = 'book/form.tt';

      # Name form, or use default 'Book::Add'
      my $validated = $self->update_from_form( $id, 'Book' ); 
      return if !$validated; # This (re)displays the form, because it's the
                             # 'end' of the method, and the 'default end' action
                             # takes over, which is to render the view
      # or simpler syntax: return unless $self->update_from_form( $id, 'Book');

      # get the new book that was just created by the form
      my $new_book = $c->stash->{form}->item;

      $c->res->redirect($c->uri_for('list'));
   }

Or configure model_name and form_name_space for the entire app:

   MyApp->config( { 'Controller::HTML::FormHandler' => 
          { model_name => 'DB', form_name_space => 'MyApp::Form' }} );

(Note that the config key does not use "Role".)

=cut

has 'form_name_space' => ( isa => 'Str|Undef', is => 'rw' );
has 'model_name' => ( isa => 'Str', is => 'rw' );
has 'model' => (  is => 'rw' );
has 'ctx' => ( isa => 'Catalyst', is => 'rw' );
has 'fif' => ( isa => 'Bool', is => 'rw', default => 0 );


sub build_per_context_instance {
   my ( $self, $c ) = @_;

   $self->ctx( $c );
   $self->form_name_space( $self->config->{form_name_space} ||
      $c->config->{'Controller::HTML::FormHandler'}->{form_name_space} || '' );
   if ($self->form_name_space eq '')
   {
      my $package = $c->action->class;
      $package =~ s/::C(?:ontroller)?::/::Form::/;
      $self->form_name_space( $package );
   }
   $self->model_name( $self->config->{model_name} ||
      $c->config->{'Controller::HTML::FormHandler'}->{model_name} || '' );
   $self->model( $c->model( $self->model_name ) ) if $self->model_name;
   $self->fif( $self->config->{fif} ||
      $c->config->{'Controller::HTML::FormHandler'}->{fif} || 0 );
   return $self;
}

=head1 Config Options

=over 4

=item model_name

Set the Catalyst model name. Currently only used by
L<HTML::FormHandler::Model::DBIC> to set the schema.

=item form_name_space

Set the name space to look for forms. Otherwise, forms will
be found in a "Form" directory parallel to the controller directory.
Override with "+" and complete package name. 

=head1 METHODS

=over 4

=item get_form

Determine the form package name, and "require" the form.
Massage the parameters into the form expected by FormHandler,
including getting the schema from the model name and passing it
into the DBIC model. Put the form object into the Catalyst stash.

=cut

sub get_form
{
   my ( $self, $args_ref, $form_name, $model_name ) = @_;

   # Determine the form package name
   $form_name ||= ucfirst( $self->ctx->action->name );
   my $form_prefix = $self->form_name_space . "::";
   my $package = $form_name =~ s/^\+// ? $form_name : $form_prefix . $form_name;
   $package->require
      or die "Failed to load Form module $package";

   # Single argument to FormHandler->new means it's an item id or object.
   # Hash references must be turned into lists.
   my %args;
   if ( defined $args_ref )
   {
      if ( ref $args_ref eq 'HASH' )
      {
         %args = %{$args_ref};
      }
      elsif ( blessed($args_ref) )
      {
         %args = (
            item    => $args_ref,
            item_id => $args_ref->id,
         );
      }
      else
      {
         %args = ( item_id => $args_ref );
      }
   }
   # Save the Catalyst context
   $args{user_data}{context} = $self->ctx;

   # Get schema from model
   if ( $package->isa('HTML::FormHandler::Model::DBIC') )
   {
      # schema only exists for DBIC model
      die "Form $package must have an item or a schema (via model_name)" 
            unless ( $self->model || $args{item} );
      $args{schema} = $self->model->schema if $self->model;
   }
   if ( $self->form_posted ) # to allow access to params for form building
   {
      $args{params} = $self->ctx->req->parameters;
   }
   return $self->ctx->stash->{form} = $package->new(%args);
} 

=item validate_form

Validate the form

=cut

sub validate_form
{
   my $self = shift;
   my $form = $self->get_form(@_);
   my $validated = $form->validate( $self->ctx->req->parameters )
      if $self->form_posted;
   $self->ctx->stash( fillinform => $form->fif ) if $self->fif;
   return $validated;
}

=item update_from_form

Use for forms that have a database interface

=cut

sub update_from_form
{
   my $self = shift;

   my $form = $self->get_form(@_);
   my $validated = $form->update_from_form( $self->ctx->req->parameters )
      if $self->form_posted;
   $self->ctx->stash( fillinform => $form->fif ) if $self->fif;
   return $validated;
}

=item form_posted

convenience method checking for POST

=cut

sub form_posted
{
   my ($self) = @_;
   return $self->ctx->req->method eq 'POST';
}



=head1 AUTHOR

Gerda Shank, modeled on Catalyst::Plugin::Form::Processor by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
