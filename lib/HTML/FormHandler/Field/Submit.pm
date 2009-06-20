package HTML::FormHandler::Field::Submit;

use Moose;
extends 'HTML::FormHandler::Field';

=head1 NAME

HTML::FormHandler::Field::Submit - submit field

=head1 SYNOPSIS

Use this field to declare a submit field in your form.

   has_field 'submit' => ( type => Submit', value => 'Save' );

It will be used by L<HTML::FormHandler::Render::Simple> to construct
a form with C<< $form->render >>.

Uses the 'submit' widget.

=cut

has 'value' => (
   is        => 'rw',
   predicate => 'has_value',
   default   => 'Save'
);

has '+widget'    => ( default => 'submit' );
has '+writeonly' => ( default => 1 );
has '+noupdate'  => ( default => 1 );

sub validate_field { }

sub clear_value { }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
