use Test::More tests => 2;


use_ok( 'HTML::FormHandler' );

{
   package My::Form;
   use Moose;
   extends 'HTML::FormHandler';

   sub profile {
       return {
           fields    => {
               price       => {
                  type => 'Integer',
                  value_sprintf => "%.2f",
               }
           },
       };
   }
}

my $form = My::Form->new;

my $params = {
   price => '1234',
};

$form->validate($params);

my $price = $form->value('price');
is( $price, '1234.00', 'format value' );

