package BookDB::Controller::Book;

BEGIN {
   use Moose;
   extends 'Catalyst::Controller';
}

use BookDB::Form::User;

has 'form' => ( isa => 'BookDB::Form::Book', is => 'rw',
   lazy => 1, default => sub { BookDB::Form::Book->new } );

=head1 NAME

BookDB::Controller::User

=head1 SYNOPSIS

An example of a non-database form

=head1 DESCRIPTION

User Controller 

=cut


sub user_base : Chained PathPart('author') CaptureArgs(0)
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

   my $users = [ $c->model('DB::User')->all ];
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

   $c->stash( form => $self->form, template => 'user/form.tt',
      action => $c->chained_uri_for->as_string );
   return unless $self->form->validate( 
      init_object => $c->stash->{user}->inflated_columns,
      params => $c->req->parameters );
   my $result = $self->form->values;
   $c->stash->{user}->update_or_create($result);
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
