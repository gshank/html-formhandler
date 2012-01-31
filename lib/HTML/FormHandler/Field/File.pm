package HTML::FormHandler::Field::File;
# ABSTRACT: simple file field; does no processing
use Moose;
extends 'HTML::FormHandler::Field';

=head1 SYNOPSIS

This field does nothing and is here mainly for testing purposes. If you use this
field you'll have to handle the actual uploaded file yourself.

See L<HTML::FormHandler::Field::Upload>

=cut

has '+widget' => ( default => 'Upload' );
has '+type_attr' => ( default => 'file' );

1;
