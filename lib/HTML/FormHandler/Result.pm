package HTML::FormHandler::Result;

use Moose;
with 'HTML::FormHandler::Role::Result';
# this will be the form result object.

=head1 NAME

HTML::FormHandler::Result

=head1 SYNOPSIS

This is the Result object that maps to the Form.

=cut

has 'form' => ( isa => 'HTML::FormHandler', is => 'ro' );


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
