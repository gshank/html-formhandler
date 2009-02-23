package BookDB::Controller::User;

BEGIN {
   use Moose;
   extends 'Catalyst::Controller';
}

use BookDB::Form::User;

has 'user_form' => ( isa => 'BookDB::Form::User', is => 'rw',
   lazy => 1, default => sub { BookDB::Form::User->new } );

=head1 NAME

BookDB::Controller::User

=head1 SYNOPSIS

An example of a non-database form

=head1 DESCRIPTION

User Controller 

=cut


sub user_base : Chained PathPart('user') CaptureArgs(0)
{
   my ( $self, $c ) = @_;
}

sub default : Chained('user_base') PathPart('') Args
{
   my ( $self, $c ) = @_;
   return $self->do_list($c);
}

sub list : Chained('user_base') PathPart('list') Args(0)
{
   my ( $self, $c ) = @_;
   return $self->do_list($c);
}

sub do_list
{
   my ( $self, $c ) = @_;

   my $users = $c->model('DB::User');
   $c->stash( users => $users, template => 'user/list.tt' );
}

sub create : Chained('user_base') PathPart('create') Args(0)
{
   my ( $self, $c ) = @_;
   # Create the empty user row for the form
   $c->stash( user => $c->model('DB::User')->new_result({}) );
   return $self->form($c);
}

sub item : Chained('user_base') PathPart('') CaptureArgs(1)
{
   my ( $self, $c, $user_id ) = @_;
   $c->stash( user => $c->model('DB::User')->find($user_id) );
}

sub edit : Chained('item') PathPart('edit') Args(0)
{
   my ( $self, $c ) = @_;
   return $self->form($c);
}

sub form
{
   my ( $self, $c ) = @_;

   my $user = $c->stash->{user};
   $c->stash( form => $self->user_form, template => 'user/form.tt',
      action => $c->chained_uri_for->as_string );
   # this is quite silly... Taking the data from the database
   # and storing it again outside of FormHandler
   # but it demonstrates the use of a non-db form
   my $user_hashref = {
      user_name => $user->user_name,
      fav_cat => $user->fav_cat,
      fav_book => $user->fav_book,
      occupation => $user->occupation }; 
   $self->user_form->validate( 
      init_object => $user_hashref,
      params => $c->req->parameters );
   return unless $self->user_form->validated;
   my $result = $self->user_form->values;
   $user->set_columns($result);
   $user->update_or_insert;
   $c->res->redirect( $c->uri_for('list') );
}

sub delete : Chained('item') PathPart('delete') Args(0)
{
   my ( $self, $c ) = @_;

   $c->stash->{user}->delete;
   $c->res->redirect( $c->uri_for('list') );
}

sub view : Chained('item') PathPart('') Args(0) { }


=back

=head1 AUTHOR

Gerda Shank

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
