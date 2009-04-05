package BookDB::Controller::Borrower;

BEGIN {
   use Moose;
   extends 'Catalyst::Controller';
}

use BookDB::Form::Borrower;
has 'my_form' => ( isa => 'BookDB::Form::Borrower', is => 'rw',
   lazy => 1, default => sub { BookDB::Form::Borrower->new } );

=head1 NAME

BookDB::Controller::Borrower

=head1 DESCRIPTION

Controller for Borrower 

=cut


sub borrower_base : Chained PathPart('borrower') CaptureArgs(0)
{
   my ( $self, $c ) = @_;
}

sub default : Chained('borrower_base') PathPart('') Args
{
   my ( $self, $c ) = @_;
   return $self->do_list($c);
}

sub list : Chained('borrower_base') PathPart('list') Args(0)
{
   my ( $self, $c ) = @_;
   return $self->do_list($c);
}

sub do_list
{
   my ( $self, $c ) = @_;

   my $borrowers = [ $c->model('DB::Borrower')->all ];
   my @columns = ( 'name', 'email' );
   $c->stash( borrowers => $borrowers, columns => \@columns,
              template => 'borrower/list.tt' );
}

sub add : Chained('borrower_base') PathPart('add') Args(0)
{
   my ( $self, $c ) = @_;
   # Create the empty borrower row for the form
   $c->stash( borrower => $c->model('DB::Borrower')->new_result({}) );
   return $self->form($c);
}

sub item : Chained('borrower_base') PathPart('') CaptureArgs(1)
{
   my ( $self, $c, $borrower_id ) = @_;
   $c->stash( borrower => $c->model('DB::Borrower')->find($borrower_id) );
}

sub edit : Chained('item') PathPart('edit') Args(0)
{
   my ( $self, $c ) = @_;
   return $self->form($c);
}

sub form
{
   my ( $self, $c ) = @_;

   $c->stash( form => $self->my_form, template => 'borrower/form.tt',
      action => $c->uri_for($c->action, $c->req->captures ));
   return unless $self->my_form->process( item => $c->stash->{borrower},
      params => $c->req->parameters );
   $c->res->redirect( $c->uri_for($self->action_for('list')) );
}

sub delete : Chained('item') PathPart('delete') Args(0)
{
   my ( $self, $c ) = @_;

   $c->stash->{borrower}->delete;
   $c->res->redirect( $c->uri_for($c->action_for('list')) );
}

sub view : Chained('item') PathPart('') Args(0)
{
   my ( $self, $c, $id ) = @_;

   my @columns = ( 'name', 'email', 'phone', 'url', 'active' );
   $c->stash( columns => \@columns, template => 'borrower/view.tt' );
}


=head1 AUTHOR

Gerda Shank

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
