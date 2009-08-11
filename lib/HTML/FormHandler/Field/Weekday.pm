package HTML::FormHandler::Field::Weekday;

use Moose;
extends 'HTML::FormHandler::Field::Select';
our $VERSION = '0.01';

sub build_options
{
   my $i    = 0;
   my @days = qw/
      Sunday
      Monday
      Tuesday
      Wednesday
      Thursday
      Friday
      Saturday
      /;
   return [ map { { value => $i++, label => $_ } } @days ];
}

=head1 NAME

HTML::FormHandler::Field::Weekday - Select valid day of the week

=head1 DESCRIPTION

Creates an option list for the days of the week.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
