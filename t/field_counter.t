use Test::More tests => 4;


use_ok( 'HTML::FormHandler' );

my $form = My::Form->new;

$form->field('field_one')->set_order;
$form->field('field_two')->set_order;
$form->field('field_three')->set_order;
$form->field('field_four')->set_order;
$form->field('field_five')->set_order;


is( $form->field('field_one')->order, 1, 'first field order');
is( $form->field('field_five')->order, 5, 'last field order');
is( $form->field_counter, 6, 'field counter value');


package My::Form;
use strict;
use warnings;
use base 'HTML::FormHandler';

sub field_list {
    return {
        fields    => {
            field_one => 'Text',
            field_two => 'Text',
            field_three => 'Text',
            field_four => 'Text',
            field_five => 'Text',
        },
    };
}

