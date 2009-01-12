package BookDB::Form::Field::AltText;

use Moose;
extends 'HTML::FormHandler::Field::Text';


has 'another_attribute' => ( isa => 'Str', is => 'rw' );

sub validate
{
   my $field = shift;

   return unless $field->SUPER::validate;
   
   my $input = $field->input;
   my $check = $field->another_attribute;
   # do something silly
   return $field->add_error('Fails AltText validation')
       unless $input =~ m/$check/; 

   return 1;
}

no Moose;
1;
