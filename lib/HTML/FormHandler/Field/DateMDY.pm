package HTML::FormHandler::Field::DateMDY;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
use DateTime;

has 'year_start' => ( isa => 'Int', is => 'rw', default => '2007' );
has 'year_end' => ( isa => 'Int', is => 'rw', default => '2020' );

apply ( [
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
      }, message => 'month is not valid' },
   {  check => sub {
         my $day = shift->{day};
         return $day =~ /^\d+$/ &&
                $day > 0 && $day <= 31;
      }, message => 'day is not valid' },
   {  check => sub {
         my $datehash = shift;
         my $year = $datehash->{year};
         if( $year =~ /^\d\d$/ )
         {
            $datehash->{year} = "20" . $year;
         }
         return $year =~ /^\d+$/;
      }, message => 'Year is not valid' },
   {  transform => sub {
         return DateTime->new($_[0] );
      }, message => 'Not a valid date' },

]);

sub validate
{
   my $self = shift;
   return unless (blessed $self->value && $self->value->isa('DateTime'));
   my $year = $self->value->year;
   $self->add_error("Not a valid year") unless ($year >= $self->year_start && $year <= $self->year_end );
}

=head1 NAME

HTML::FormHandler::Field::DateMDY

=head1 SYNOPSIS

For date fields in the format nn/nn/nnnn. An example of a date
class using constraint actions.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
