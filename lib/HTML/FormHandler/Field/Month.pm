package HTML::FormHandler::Field::Month;

use Moose;
extends 'HTML::FormHandler::Field::IntRange';
our $VERSION = '0.01';

has '+range_start' => ( default => 1 );
has '+range_end' => ( default => 12 );

__PACKAGE__->meta->make_immutable;


=head1 NAME

HTML::FormHandler::Field::Month - Select list of 1 to 12

=head1 DESCRIPTION

Select list for range of 1 to 12. Widget type is 'select'

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
