package HTML::FormHandler::Field::NoValue;

use Moose;
extends 'HTML::FormHandler::Field';

=head1 NAME

HTML::FormHandler::Field::NoValue 

=head1 SYNOPSIS

This is the base class for the Submit field. It can be used for fields that
are do not produce valid 'values'. It should not be used for fields that 
produce a value or need validating.

=cut

has 'html' => ( is => 'rw', isa => 'Str', default => '' );
has 'value' => (
    is        => 'rw',
    predicate => 'has_value',
    clearer   => 'clear_value',
);

sub _result_from_fields {
    my ( $self, $result ) = @_;
    $self->_set_result($result);
    $result->_set_field_def($self);
    return $result;
}

sub _result_from_input {
    my ( $self, $result, $input, $exists ) = @_;
    $self->_set_result($result);
    $result->_set_field_def($self);
    return $result;
}

sub _result_from_object {
    my ( $self, $result, $value ) = @_;
    $self->_set_result($result);
    $result->_set_field_def($self);
    return $result;
}

sub fif { }

has '+widget'    => ( default => '' );
has '+writeonly' => ( default => 1 );
has '+noupdate'  => ( default => 1 );

sub validate_field { }

#sub clear_value { }

sub render {
    my $self = shift;
    return $self->html;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
