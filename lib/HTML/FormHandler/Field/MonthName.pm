package HTML::FormHandler::Field::MonthName;

use Moose;
extends 'HTML::FormHandler::Field::Select';
our $VERSION = '0.01';

sub build_options
{
   my $i      = 1;
   my @months = qw/
      January
      February
      March
      April
      May
      June
      July
      August
      September
      October
      November
      December
      /;
   return [ map { { value => $i++, label => $_ } } @months ];
}

=head1 NAME

HTML::FormHandler::Field::MonthName - Select list for month names

=head1 DESCRIPTION

Generates a list of English month names.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
