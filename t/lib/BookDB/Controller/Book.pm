package BookDB::Controller::Book;

BEGIN {
   use Moose;
   extends 'Catalyst::Controller';
}

use BookDB::Form::Book;
use BookDB::Form::BookView;

has 'edit_form' => ( isa => 'BookDB::Form::Book', is => 'rw',
   lazy => 1, default => sub { BookDB::Form::Book->new( verbose => 1 ) } );
has 'view_form' => ( isa => 'BookDB::Form::BookView', is => 'rw',
   lazy => 1, default => sub { BookDB::Form::BookView->new } );

=head1 NAME

BookDB::Controller::Book

=head1 SYNOPSIS

See L<BookDB>

=head1 DESCRIPTION

Book Controller 

=cut


sub book_base : Chained PathPart('book') CaptureArgs(0)
{
   my ( $self, $c ) = @_;
}

sub default : Chained('book_base') PathPart('') Args
{
   my ( $self, $c ) = @_;
   return $self->do_list($c);
}

sub list : Chained('book_base') PathPart('list') Args(0)
{
   my ( $self, $c ) = @_;
   return $self->do_list($c);
}

sub do_list
{
   my ( $self, $c ) = @_;

   my $books = [ $c->model('DB::Book')->all ];
   my @columns = ( 'title', 'author', 'publisher', 'year' );
   $c->stash( books => $books, columns => \@columns,
              template => 'book/list.tt' );
}

sub create : Chained('book_base') PathPart('create') Args(0)
{
   my ( $self, $c ) = @_;
   # Create the empty book row for the form
   $c->stash( book => $c->model('DB::Book')->new_result({}) );
   return $self->form($c);
}

sub item : Chained('book_base') PathPart('') CaptureArgs(1)
{
   my ( $self, $c, $book_id ) = @_;
   $c->stash( book => $c->model('DB::Book')->find($book_id) );
}

sub edit : Chained('item') PathPart('edit') Args(0)
{
   my ( $self, $c ) = @_;
   return $self->form($c);
}

sub form
{
   my ( $self, $c ) = @_;

   $c->stash( form => $self->edit_form, template => 'book/form.tt',
      action => $c->chained_uri_for->as_string );
   return unless $self->edit_form->process( item => $c->stash->{book},
      params => $c->req->parameters );
   $c->res->redirect( $c->uri_for('list') );
}

sub delete : Chained('item') PathPart('delete') Args(0)
{
   my ( $self, $c ) = @_;

   $c->stash->{book}->delete;
   $c->res->redirect( $c->uri_for('list') );
}

sub view : Chained('item') PathPart('') Args(0)
{
   my ( $self, $c, $id ) = @_;

   $c->stash( form => $self->view_form, template => 'book/view.tt' );
   return unless $self->view_form->process( item => $c->stash->{book},
      params => $c->req->parameters  );
   $c->stash->{message} = 'Book checked out';
}

sub do_return : Chained('item') PathPart('return') Args(0)
{
   my ( $self, $c ) = @_;

   my $book = $c->stash->{book};
   $book->borrowed(undef);
   $book->borrower(undef);
   $book->update;

   $c->res->redirect( '/book/' . $book->id );
   $c->detach;
}

=back

=head1 AUTHOR

Gerda Shank

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
