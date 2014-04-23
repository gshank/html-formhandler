use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+use_init_obj_when_no_accessor_in_item' => ( default => 1 );
    has_field 'foo';
    has_field 'bar';
    has_field 'max';
    has_field 'my_comp' => ( type => 'Compound' );
    has_field 'my_comp.one';
    has_field 'my_comp.two';
}

my $form = Test::Form->new;
my $item = { foo => 'item_foo', bar => 'item_bar' };
my $init_obj = { max => 'init_obj_max' };

$form->process( item => $item, init_object => $init_obj, params => {} );
is( $form->field('foo')->fif, 'item_foo' );
is( $form->field('bar')->fif, 'item_bar' );
is( $form->field('max')->fif, 'init_obj_max', 'init_obj value pulled in' );

$init_obj = { my_comp => { one => 'init_obj_one', two => 'init_obj_two' } };
$form->process( item => $item, init_object => $init_obj, params => {} );
is( $form->field('foo')->fif, 'item_foo' );
is( $form->field('bar')->fif, 'item_bar' );
is( $form->field('max')->fif, '' );
is( $form->field('my_comp.one')->fif, 'init_obj_one', 'init_obj value pulled in for compound' );

$init_obj = { foo => 'init_obj_foo', bar => 'init_obj_bar', max => 'init_obj_max',
    my_comp => { one => 'init_obj_one', two => 'init_obj_two' } };

$item = undef;
$form->process( item => $item, init_object => $init_obj, params => {} );
is( $form->field('foo')->fif, 'init_obj_foo' );
is( $form->field('bar')->fif, 'init_obj_bar' );
is( $form->field('max')->fif, 'init_obj_max' );
is( $form->field('my_comp.one')->fif, 'init_obj_one', 'init_obj value pulled in for compound' );

$item = { foo => 'item_foo', bar => 'item_bar' };
$form->process( item => $item, init_object => $init_obj, params => {} );
is( $form->field('foo')->fif, 'item_foo' );
is( $form->field('bar')->fif, 'item_bar' );
is( $form->field('max')->fif, 'init_obj_max' );
is( $form->field('my_comp.one')->fif, 'init_obj_one', 'init_obj value pulled in for compound' );

# test form reuse
$form->process( params => {} );
is( $form->field('foo')->fif, '' );
is( $form->field('bar')->fif, '' );
is( $form->field('max')->fif, '' );
is( $form->field('my_comp.one')->fif, '', "all fields empty on form reuse with init_object" );

# test params_to_values method
my $params = {
   foo => 'one',
   bar => 'two',
   max => 'three',
   'my_comp.one' => 'xxx',
   'my_comp.two' => 'yyy',
};
$init_obj = $form->params_to_values($params);
$form->process( init_object => $init_obj, params => {} );
is_deeply( $form->fif, $params, 'fif is the same as params' );
is_deeply( $form->value, $init_obj, 'value is the same as init_obj');

done_testing;
