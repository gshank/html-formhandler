package HTML::FormHandler::Field::Submit;

use Moose;
extends 'HTML::FormHandler::Field::Display';

=head1 NAME

HTML::FormHandler::Field::Submit - submit field

=head1 SYNOPSIS

Use this field to declare a submit field in your form.

   has_field 'submit' => ( type => 'Submit', value => 'Save' );

It will be used by L<HTML::FormHandler::Render::Simple> to construct
a form with C<< $form->render >>.

Uses the 'submit' widget.

=cut

has '+value' => ( default => 'Save' );
has '+widget' => ( default => 'submit' );
has 'store_in_result' => ( is => 'ro', isa => 'Bool' );

sub _result_from_input 
{
   my ( $self, $result, $input, $exists ) = @_;

   # normally we don't want the submit field stored in the result
   # since it is static. but if people have multiple submit fields
   # and want to check the result, maybe it should be stored...
   if( $self->store_in_result ) {
      $result->_set_input($input);
      $self->_set_result($result);
      $result->_set_field_def($self);
      return $result;
   }
   else {
      $self->result->_set_input($input);
   }
   return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
