use Test::More tests => 2;


use_ok( 'HTML::FormHandler' );

my $form = My::Form->new;

my $params = {
   price => '1234',
};

$form->validate($params);

my $price = $form->field('price')->value;
is( $price, '1234.00', 'format value' );

package My::Form;
use strict;
use warnings;
use base 'HTML::FormHandler';

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







