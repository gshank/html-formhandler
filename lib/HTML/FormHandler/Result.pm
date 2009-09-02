package HTML::FormHandler::Result;

use Moose;
with 'HTML::FormHandler::Result::Role';

=head1 NAME

HTML::FormHandler::Result

=head1 SYNOPSIS

This is the Result object that maps to the Form.

=cut

has 'form' => ( isa => 'HTML::FormHandler', is => 'ro', weak_ref => 1,
#  handles => ['render' ]
);


has 'ran_validation' => ( is => 'rw', isa => 'Bool', default => 0 );

sub fif
{
   my $self = shift;
   $self->form->fields_fif( $self );
}

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

Initially based on the original source code of L<Form::Processor::Field> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
