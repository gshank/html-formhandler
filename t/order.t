use Test::More tests => 3;


use_ok( 'HTML::FormHandler' );

{
   package My::Form;
   use Moose;
   extends 'HTML::FormHandler';

   sub field_list {
       return {
           fields    => [
               field_one => 'Text',
               field_two => 'Text',
               field_three => 'Text',
               field_four => 'Text',
               field_five => 'Text',
           ],
       };
   }
}

my $form = My::Form->new;

is( $form->field('field_one')->order, 1, 'first field order');
is( $form->field('field_five')->order, 5, 'last field order');


