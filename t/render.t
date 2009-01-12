use Test::More tests => 4;

use HTML::FormHandler::Field::Text;


{
   package Test::Form;
   use Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::Simple';

   sub profile
   {
      return {
         fields => {
            TestField => {
               type => 'Text',
               label => 'TEST',
               id    => 'f99',
               value => 'something'
            },
         }
      }
   }
}

my $form = Test::Form->new;

ok( $form, 'create form');

my $output = $form->field_render( 'TestField' );
ok( $output, 'get rendered output');

$output = $form->render_field( $form->field('TestField') );
ok( $output, 'get rendered output from field obj');

$output = $form->render;
ok( $output, 'get rendered output from form');
