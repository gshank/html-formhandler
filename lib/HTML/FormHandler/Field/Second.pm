package HTML::FormHandler::Field::Second;

use Moose;
extends 'HTML::FormHandler::Field::IntRange';
our $VERSION = '0.01';

has '+range_start' => ( default => 0 );
has '+range_end'   => ( default => 59 );

=head1 NAME

HTML::FormHandler::Field::Second - Select list for seconds

=head1 DESCRIPTION

A select field for seconds in the range of 0 to 59.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
