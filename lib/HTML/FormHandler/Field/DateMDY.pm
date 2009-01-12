package HTML::FormHandler::Field::DateMDY;

use Moose;
extends 'HTML::FormHandler::Field';

sub validate
{

   my $field = shift;

   return unless $field->SUPER::validate;

   my ($month, $day, $year) = split /\//, $field->input;
   # check for digits
   unless( $month =~ /^\d+$/ && $day =~ /^\d+$/ && $year =~ /^\d+$/ )
   {
      return $field->add_error( 'Invalid date');
   } 
   # check for the right digits
   unless ($month > 0 && $month < 13)
   {
      $field->add_error( 'Month is not valid' );
   }
   unless ($day > 0 && $day < 32)
   {
      $field->add_error( 'Day is not valid' );
   }
   unless ($year > 2007 && $year < 2020 )
   {
      $field->add_error( 'Year is not vaid' );
   }
   return if $field->has_errors;
   return 1;
}

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
