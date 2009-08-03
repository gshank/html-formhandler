package HTML::FormHandler::Field::DateMDY;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Date';

has '+format' => ( default => '%m/%d/%Y' );

=head1 NAME

HTML::FormHandler::Field::DateMDY

=head1 SYNOPSIS

For date fields in the format nn/nn/nnnn. This simply inherits
from L<HTML::FormHandler::Field::Date> and sets the format
to "%m/%d/%Y".

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
