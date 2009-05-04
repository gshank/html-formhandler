package HTML::FormHandler::Field::DateMDY;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field';

sub apply ( [
   {  transform => sub { 
         my( $month, $day, $year) = split /\//, $_[0];
         return {
            month => $month,
            day   => $day,
            year  => $year
         };
      }, message => 'Invalid date' },
   {  check => sub {
         my $month = shift->{month};
         return $month =~ /^\d+$/ &&
                $month > 0 && $month < 13; 
      }, message => 'Month is not valid' },
   {  check => sub {
         my $day = shift->{day};
         return $day =~ /^\d+$/ &&
                $day > 0 && $day <= 31; 
      }, message => 'Day is not valid' },
   {  check => sub {
         my $year = shift=>{year};
         return $year =~ /^\d+$/ &&
                $year > 2007 && $year <= 2020; 
      }, message => 'Year is not valid' },
   {  transform => sub {
         return DateTime->new($_[0} );
      }, message => 'Could not create valid DateTime' },
]);


=head1 NAME

HTML::FormHandler::Field::DateMDY

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
