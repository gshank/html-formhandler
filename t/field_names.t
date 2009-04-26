use strict;
use warnings;
use Test::More tests => 6;


{
   package Field::Four;

   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Field::Compound';

   has_field 'one' => ( type => 'Compound' );
   has_field 'two';
   has_field 'one.one';
}

{
   package Names::Form;

   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'field_one' => ( type => 'Compound' );
   has_field 'field_three' => ( type => 'Compound' );;

   has_field 'field_one.one' => ( type => 'Compound' );
   has_field 'field_one.three';
   has_field 'field_three.one';
   has_field 'field_two.one';
   has_field 'field_one.one.one';
   has_field 'field_one.one.two';

   has_field 'field_two' => ( type => 'Compound' );
   has_field 'field_four' => ( type => '+Field::Four' );

}

my $form = Names::Form->new;
ok($form, 'names form');

ok( $form->field('field_four'), 'get field four');
ok( $form->field('field_four')->field('two'), 'get field_four + two');
ok( $form->field('field_four.two'), 'get field_four.two');
ok( $form->field('field_one')->field('one')->field('one'), 
     'get field_one + one + one');
ok( $form->field('field_one.one.one'), 'get field_one.one.one');

