package HTML::FormHandler::Field::Submit;

use Moose;
extends 'HTML::FormHandler::Field::NoValue';

=head1 NAME

HTML::FormHandler::Field::Submit - submit field

=head1 SYNOPSIS

Use this field to declare a submit field in your form.

   has_field 'submit' => ( type => 'Submit', value => 'Save' );

It will be used by L<HTML::FormHandler::Render::Simple> to construct
a form with C<< $form->render >>.

Uses the 'submit' widget.

If you have multiple submit buttons, currently the only way to test
which one has been clicked is with C<< $field->input >>. The 'value'
attribute is used for the HTML input field 'value'. 

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
