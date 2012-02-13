package HTML::FormHandler::Field::BoolSelect;
# ABSTRACT: Boolean select field

=head1 SYNOPSIS

A Boolean select field with three states: null, 1, 0.
Empty select is 'Select One'.

=cut

use Moose;
extends 'HTML::FormHandler::Field::Select';

has '+empty_select' => ( default => 'Select One' );

sub build_options { [
    { value => 1, label => 'True'},
    { value => 0, label => 'False' }
]};


__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
