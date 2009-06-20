package HTML::FormHandler::Field::Hidden;

use Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

has '+widget' => ( default => 'hidden' );

=head1 NAME

HTML::FormHandler::Field::Hidden

=head1 DESCRIPTION

This is a text field that uses the 'hidden' widget type, for HTML
of type 'hidden'.

=head1 AUTHORS

Zbigniew Lukasiak

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
