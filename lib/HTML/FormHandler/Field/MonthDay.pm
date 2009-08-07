package HTML::FormHandler::Field::MonthDay;

use Moose;
extends 'HTML::FormHandler::Field::IntRange';
our $VERSION = '0.01';

has '+range_start' => ( default => 1 );
has '+range_end'   => ( default => 31 );

=head1 NAME

HTML::FormHandler::Field::MonthDay - Select list for a day number 1 to 31

=head1 DESCRIPTION

Generates a select list for integers 1 to 31.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
