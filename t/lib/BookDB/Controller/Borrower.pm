package BookDB::Controller::Borrower;

use Moose;
use base 'Catalyst::Controller';
with 'Catalyst::Controller::Role::HTML::FormHandler';

=head1 NAME

BookDB::Controller::Borrower

=head1 SYNOPSIS

See L<BookDB>

=head1 DESCRIPTION

Controller for Borrower 

=head1 METHODS

=over 4

=item add

Sets a template.

=cut

__PACKAGE__->config( model_name => 'DB', form_name_space => 'BookDB::Form' );

sub add : Local
{
   my ( $self, $c ) = @_;

   $c->forward('do_form');
}

=item form

Handles displaying and validating the form
Will save to the database on validation

=cut

sub do_form : Private
{
   my ( $self, $c, $id ) = @_;

   # Set template
   $c->stash->{template} = 'borrower/form.tt';
   # Fill form Al Gore
$DB::single=1;
   my $validated = $self->update_from_form( $id, 'Borrower' );

   # this could also be
   # return unless $c->update_from_form( $id, 'Borrower');
   # but that makes it difficult to look at with the debugger.
   return if !$validated;    # This (re)displays the form, because it's the
                             # 'end' of the method, and the 'default end' action
                             # takes over, which is to render the view

   # get the new borrower that was just created by the form
   my $new_borrower = $c->stash->{form}->item;
   $c->res->redirect( $c->uri_for('list') );
}

=item default

Forwards to list.

=cut

sub default : Private
{
   my ( $self, $c ) = @_;
   $c->res->redirect( $c->uri_for('list') );
}

=item destroy

Destroys a row and forwards to list.

=cut

sub destroy : Local
{
   my ( $self, $c, $id ) = @_;
   $c->model('DB::Borrower')->find($id)->delete;
   $c->stash->{message} = 'Borrower deleted';
   $c->res->redirect( $c->uri_for('list') );
}

=item do_add

Adds a new row to the table and forwards to list.

=cut

=item edit

Sets a template.

=cut

sub edit : Local
{
   my ( $self, $c, $id ) = @_;

   $c->forward('do_form');
}

=item list

Sets a template.

=cut

sub list : Local
{
   my ( $self, $c ) = @_;

   # get an array of row objects
   my $borrowers = [ $c->model('DB::Borrower')->all ];
   my @columns = ( 'name', 'email' );

   $c->stash->{borrowers} = $borrowers;
   $c->stash->{columns}   = \@columns;
   $c->stash->{template}  = 'borrower/list.tt';
}

=item view

Fetches a row and sets a template.

=cut

sub view : Local
{
   my ( $self, $c, $id ) = @_;

   # get row object for this borrower id
   my $borrower = $c->model('DB::Borrower')->find($id);
   # list of columns in order for form
   my @columns = ( 'name', 'email', 'phone', 'url' );

   my $rel = $c->model('DB')->source('Borrower')->relationship_info('books');
   $c->stash->{columns}  = \@columns;
   $c->stash->{borrower} = $borrower;
   $c->stash->{template} = 'borrower/view.tt';
}

=back

=head1 AUTHOR

Gerda Shank

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
