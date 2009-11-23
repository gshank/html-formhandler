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

has '+value'  => ( default => 'Save' );
has '+widget' => ( default => 'submit' );

sub _result_from_input {
    my ( $self, $result, $input, $exists ) = @_;
    $self->_set_result($result);
    $result->_set_input($input);
    $result->_set_field_def($self);
    return $result;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
