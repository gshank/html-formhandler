package HTML::FormHandler::Result;
# ABSTRACT: form result object

use Moose;
# following is to allow the form to return an empty
# hashref when value is undefined, without messing
# with the way 'value' works for fields
with 'HTML::FormHandler::Result::Role';
with 'HTML::FormHandler::Traits';

=head1 SYNOPSIS

This is the Result object that maps to the Form.

    my $result = $self->form->run( $params );
    my $result2 = $self->form->run( $other_params );

    my $value = $result->field('title')->value;
    my $fif = $result->fif;
    my $field_fid = $result->field('title')->fif;

=head2 DESCRIPTION

Although not experimental, the 'results' have not been exercised as much
as the other parts of the code. If there is missing functionality or
things that don't work, please ask or report bugs.

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

Most of this object is implemented in L<HTML::FormHandler::Result::Role>,
because it is shared with L<HTML::FormHandler::Field::Result>.

=cut

has 'form' => (
    isa      => 'HTML::FormHandler',
    is       => 'ro',
    weak_ref => 1,
    handles  => ['item_values'],
    #  handles => ['render' ]
);

has '_value' => (
    is        => 'ro',
    writer    => '_set_value',
    reader    => '_get_value',
    clearer   => '_clear_value',
    predicate => 'has_value',
);

sub value { shift->_get_value || {} }

has 'form_errors' => (
    traits     => ['Array'],
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    default    => sub { [] },
    handles   => {
        all_form_errors  => 'elements',
        push_form_errors => 'push',
        num_form_errors => 'count',
        has_form_errors => 'count',
        clear_form_errors => 'clear',
    }
);

sub validated { !$_[0]->has_error_results && $_[0]->has_input && !$_[0]->has_form_errors }

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

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
