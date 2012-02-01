use strict;
use warnings;
use Test::More;

use_ok('HTML::FormHandler::Field::Repeatable');

# test to verify that contains hashref passed in to construction of
# a repeatable field is used to build the 'contains' field
my $args = {
   name => 'test_field',
   init_contains => { wrapper_class => ['hfh', 'repinst'] },
};
my $field = HTML::FormHandler::Field::Repeatable->new( %$args );
ok( $field, 'field built' );
$field->init_state;
is_deeply( $field->contains->wrapper_class, ['hfh', 'repinst'], 'attribute set' );

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'my_name';
    has_field 'my_records' => ( type => 'Repeatable', num_when_empty => 2,
        init_contains => { wrapper_class =>['hfh'] },
    );
    has_field 'my_records.one';
    has_field 'my_records.two';
}
my $form = Test::Form->new;
ok( $form, 'form built' );
is_deeply( $form->field('my_records')->contains->wrapper_class, ['hfh'], 'worked in form');
my $rendered = $form->render;


done_testing;
