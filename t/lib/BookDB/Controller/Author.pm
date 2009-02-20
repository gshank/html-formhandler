package BookDB::Controller::Author;

BEGIN {
   use Moose;
   extends 'Catalyst::Controller';
}

use BookDB::Form::User;

has 'form' => ( isa => 'BookDB::Form::Author', is => 'rw',
   lazy => 1, default => sub { BookDB::Form::Author->new } );

=head1 NAME

BookDB::Controller::Author

=head1 SYNOPSIS

An author form

=head1 DESCRIPTION

User Controller 

=cut


sub author_base : Chained PathPart('author') CaptureArgs(0)
{
   my ( $self, $c ) = @_;
}

sub default : Chained('author_base') PathPart('') Args
{
   my ( $self, $c ) = @_;
   return $self->do_list($c);
}

sub list : Chained('author_base') PathPart('list') Args(0)
{
   my ( $self, $c ) = @_;
   return $self->do_list($c);
}

sub do_list
{
   my ( $self, $c ) = @_;

   my $authors = [ $c->model('DB::Author')->all ];
   $c->stash( authors => $authors, template => 'user/list.tt' );
}

sub create : Chained('author_base') PathPart('create') Args(0)
{
   my ( $self, $c ) = @_;
   # Create the empty author row for the form
   $c->stash( author => $c->model('DB::Author')->new_result({}) );
   return $self->form($c);
}

sub item : Chained('author_base') PathPart('') CaptureArgs(1)
{
   my ( $self, $c, $author_id ) = @_;
   $c->stash( author => $c->model('DB::Author')->find($author_id) );
}

sub edit : Chained('item') PathPart('edit') Args(0)
{
   my ( $self, $c ) = @_;
   return $self->form($c);
}

sub form
{
   my ( $self, $c ) = @_;

   $c->stash( form => $self->form, template => 'author/form.tt',
      action => $c->chained_uri_for->as_string );
   return unless $self->form->validate( $c->stash->{author}, 
      params => $c->req->parameters );
   $c->res->redirect( $c->uri_for('list') );
}

sub delete : Chained('item') PathPart('delete') Args(0)
{
   my ( $self, $c ) = @_;

   $c->stash->{author}->delete;
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
