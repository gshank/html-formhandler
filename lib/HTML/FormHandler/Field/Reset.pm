package HTML::FormHandler::Field::Reset;

use Moose;
extends 'HTML::FormHandler::Field::Submit';

=head1 NAME

HTML::FormHandler::Field::Reset - reset field

=head1 SYNOPSIS

Use this field to declare a reset field in your form.

   has_field 'reset' => ( type => 'Reset', value => 'Restore' );

It's exactly same as L<HTML::FormHandler::Field::Submit>,
but use "reset" as type of input elemnt.

Uses the 'submit' widget.

=cut

has '+value' => ( default => 'Restore' );

__PACKAGE__->meta->make_immutable;
no Moose;
1;
