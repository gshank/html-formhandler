use Test::More tests => 9;


use_ok( 'HTML::FormHandler' );

{
   package My::Form::One;
   use HTML::FormHandler::Moose;

   extends 'HTML::FormHandler';

   # this form specifies the form name
   has '+name' => ( default => 'One' );
   has '+html_prefix' => ( default => 1 );

   has_field 'field_one';
   has_field 'field_two';
   has_field 'field_three';
}
my $form1 = My::Form::One->new;
ok( $form1, 'get first form' );

{
   package My::Form::Two;
   use Moose;
   extends 'HTML::FormHandler';

   # this form uses the default random form name generation
   has '+html_prefix' => ( default => 1 );

   sub field_list {
       [ 
            field_one => 'Text',
            field_two => 'Text',
            field_three => 'Text',
       ] 
   }
}
my $form2 = My::Form::Two->new;
ok( $form2, 'get second form' );

my $params = {
   'One.field_one' => 'First field in first form',
   'One.field_two' => 'Second field in first form',
   'One.field_three' => 'Third field in first form',
   $form2->field('field_one')->html_name => 
             'First field in second form',
   $form2->field('field_two')->html_name => 
              'Second field in second form',
   $form2->field('field_three')->html_name => 
              'Third field in second form',
};
$form1->process( $params );
ok( $form1->validated, 'validated first form' );
is( $form1->field('field_one')->value, 'First field in first form',
   'value of field in first form is correct' );
my $fif_params = $form1->fif;
is_deeply( $fif_params, {
   'One.field_one' => 'First field in first form',
   'One.field_two' => 'Second field in first form',
   'One.field_three' => 'Third field in first form',
   }, 'fif params correct');

$form2->process( $params );
ok( $form2->validated, 'validated second form' );
is( $form2->field('field_three')->value, 'Third field in second form',
   'value of field in second form is correct' );

$params = {
   'One.field_one' => 'First field in first form',
   'One.field_two' => 'Second field in first form',
   'One.field_three' => 'Third field in first form',
};
$form2 = My::Form::Two->new( params => $params );
ok( !$form2->has_params, 'has_params checks only params intented for the form');

