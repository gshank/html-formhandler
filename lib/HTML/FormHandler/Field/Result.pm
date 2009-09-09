package HTML::FormHandler::Field::Result;

use Moose;
with 'HTML::FormHandler::Result::Role';

=head1 NAME

HTML::FormHandler::Field::Result

=head1 SYNOPSIS

Result class for L<HTML::FormHandler::Field>

=cut

has 'field_def' => (
    is     => 'ro',
    isa    => 'HTML::FormHandler::Field',
    writer => '_set_field_def',
);

sub fif {
    my $self = shift;
    return $self->field_def->fif($self);
}

sub fields_fif {
    my ( $self, $prefix ) = @_;
    return $self->field_def->fields_fif( $self, $prefix );
}

sub render {
    my $self = shift;
    return $self->field_def->render($self);
}

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

Initially based on the original source code of L<Form::Processor::Field> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
