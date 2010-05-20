package HTML::FormHandler::Result;

use Moose;
with 'HTML::FormHandler::Result::Role';
with 'MooseX::Traits';

=head1 NAME

HTML::FormHandler::Result

=head1 SYNOPSIS

This is the Result object that maps to the Form.

    my $result = $self->form->run( $params );
    my $result2 = $self->form->run( $other_params );

    my $value = $result->field('title')->value;
    my $fif = $result->fif;
    my $field_fid = $result->field('title')->fif;

=head2 DESCRIPTION

This is currently experimental. Interfaces and interface names may change.

The original FormHandler 'process' method, when used with persistent forms,
leaves behind state data for a particular execution of 'process'. This is
not optimal or clean from an architectural point of view.
The intention with the 'result' object is to separate dynamic data from static.
The 'form' object is treated as a kind of result factory, which will spit out
results and leave the form in a consistent state.

In the current state of implementation, the result object can be used to render
a form:

   $result->render;

However there are still open questions about how much of the form/field
should be forwarded to the result. At this point, the number of forwarded
methods is minimal. Mechanisms to make this more customizable are being
considered. 

Dynamic select lists are not supported yet. Static select lists
(that are the same for every form execution) should work fine, but lists
that are different depending on some field value will not. 

Most of this object is implemented in L<HTML::FormHandler::Role::Result>,
because it is shared with L<HTML::FormHandler::Field::Result>.

=cut

has 'form' => (
    isa      => 'HTML::FormHandler',
    is       => 'ro',
    weak_ref => 1,
    #  handles => ['render' ]
);

has 'ran_validation' => ( is => 'rw', isa => 'Bool', default => 0 );

sub fif {
    my $self = shift;
    $self->form->fields_fif($self);
}

sub peek {
    my $self = shift;
    my $string = "Form Result " . $self->name . "\n";
    my $indent = '  ';
    foreach my $res ( $self->results ) {
        $string .= $res->peek( $indent );
    }
    return $string;
}

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
