use Test::More tests => 9;

use lib 't/lib';

use_ok( 'HTML::FormHandler::Field::Duration');

my $field = HTML::FormHandler::Field::Duration->new( name => 'duration' );

ok( $field, 'get compound field');

my $input = {
      hours => 1,
      minutes => 2,
};

$field->input($input);

is_deeply( $field->input, $input, 'field input is correct');

is_deeply( $field->fif, $input, 'field fif is same');

{
   package Compound::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'name' => ( type => 'Text' );
   has_field 'duration' => ( type => 'Duration' );
   has_field 'duration.hours' => ( type => 'Nested', parent => 'duration' );
   has_field 'duration.minutes' => ( type => 'Nested', parent => 'duration' );

}

my $form = Compound::Form->new;
ok( $form, 'get compound form' );
ok( $form->field('duration'), 'duration field' );
ok( $form->field('duration.hours'), 'duration.hours field' );

my $params = { name => 'Testing', 'duration.hours' => 2, 'duration.minutes' => 30 };

$form->validate( params => $params );
ok( $form->validated, 'form validated' );

is_deeply($form->fif, $params, 'get fif with right value');

