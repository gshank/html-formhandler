use Test::More tests => 3;


use_ok( 'HTML::FormHandler' );

my $form = My::Form->new;


is( $form->field('field_one')->order, 1, 'first field order');
is( $form->field('field_five')->order, 5, 'last field order');


package My::Form;
use strict;
use warnings;
use base 'HTML::FormHandler';

sub profile {
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

