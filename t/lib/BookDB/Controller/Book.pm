package BookDB::Controller::Book;

use Moose;
use base 'Catalyst::Controller';
with 'Catalyst::Controller::Role::HTML::FormHandler';
use DateTime;
use BookDB::Form::Book;

__PACKAGE__->config( form_name_space => 'BookDB::Form' );

=head1 NAME

BookDB::Controller::Book

=head1 SYNOPSIS

See L<BookDB>

=head1 DESCRIPTION

Book Controller 

=head1 METHODS

=over 4

=item add

Sets a template.

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
   # get an array of row object
   my $books = [ $c->model('DB::Book')->all ];
   # set columns in order wanted for list
   my @columns = ( 'title', 'author', 'publisher', 'year' );

   $c->stash->{books}    = $books;
   $c->stash->{columns}  = \@columns;
   $c->stash->{template} = 'book/list.tt';
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
  $c->stash->{book} = $c->model('DB::Book')->find($book_id);
}

=item edit

Handles displaying and validating the form
Will save to the database on validation

=cut

sub edit : Chained('item') PathPart('edit') Args(0)
{
   my ( $self, $c ) = @_;
   return $self->form($c);
}


sub form
{
   my ( $self, $c ) = @_;

   # Name template, otherwise it will use book/add.tt or book/edit.tt
   $self->ctx->stash->{template} = 'book/form.tt';

   # Name form, otherwise it will expect 'Book::Edit'
   my $book = $c->stash->{book};
   my $validated = $self->update_from_form( $book, 'Book' );
   $c->stash->{form}->action( $c->chained_uri_for->as_string );
   return if !$validated;    # This (re)displays the form, because it's the
                             # 'end' of the method, and the 'default end' action
                             # takes over, which is to render the view

   # get the new book that was just created by the form
   my $new_book = $c->stash->{form}->item;

   # redirect to list. 'show' also a possibility...
   $c->res->redirect( $c->uri_for('list') );
}

=item form (without Catalyst plugin)

Handles displaying and validating the form without the controller/role
methods.  Will save to the database on validation.

=cut

sub edit_alt : Chained('item') PathPart('edit_alt') CaptureArgs(0) 
{
   my ( $self, $c ) = @_;

   my $book = $c->stash->{book};
   my $form = BookDB::Form::Book->new($book);
   # put form and template in stash
   $c->stash->{form}     = $form;
   $c->stash->{template} = 'book/edit_alt.tt';

   # update form
   $form->update_from_form( $c->req->parameters ) if $c->req->method eq 'POST';
   $c->stash->{form}->action( $c->chained_uri_for->as_string );
   return unless $c->req->method eq 'POST' && $form->validated;

   # get the new book that was just created by the form
   my $new_book = $form->item;
   # redirect to list.
   $c->res->redirect( $c->uri_for('list') );
}

=item delete

Destroys a row and forwards to list.

=cut

sub delete : Chained('item') PathPart('delete') Args(0)
{
   my ( $self, $c ) = @_;

   # delete row in database
   $c->stash->{book}->delete;
   # redirect to list page
   $c->res->redirect( $c->uri_for('list') );
}

=item view

Fetches a row and sets a template.

=cut

sub view : Chained('item') PathPart('') Args(0)
{
   my ( $self, $c, $id ) = @_;

   $c->stash->{template} = 'book/view.tt';
   my $validated = $self->update_from_form( $c->stash->{book}, 'BookView' );
   return if !$validated;
$DB::single=1;
   # form validated
   $c->stash->{message} = 'Book checked out';
}

=item do_return

=cut

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

=item
=cut

=back

=head1 AUTHOR

Gerda Shank

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
