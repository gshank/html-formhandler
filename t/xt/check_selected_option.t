use strict;
use warnings;
use Test::More;

use_ok('HTML::FormHandler::Widget::Field::Role::SelectedOption');

{
    package MyFoo;

    use Moose;

    with 'HTML::FormHandler::Widget::Field::Role::SelectedOption';
}

my $fif = '09U1N2';
my $foo = MyFoo->new;

ok(!$foo->check_selected_option($fif, { value => '82HJ27' }),
    'no selected/checked key and diff values');

ok($foo->check_selected_option($fif, { value => $fif }),
    'no selected/checked key and same values');

ok(!$foo->check_selected_option($fif, {
    selected => 0,
    value => '98HH21',
}), 'with selected key, values do not matter');

ok(!$foo->check_selected_option($fif, {
    checked => 0,
    value => '98HH21',
}), 'with checked key, values do not matter');

ok(!$foo->check_selected_option($fif, {
    selected => 0,
    value => $fif,
}), 'with selected key, values do not matter');

ok(!$foo->check_selected_option($fif, {
    checked => 0,
    value => $fif,
}), 'with checked key, values do not matter');

ok($foo->check_selected_option($fif, {
    selected => 1,
    value => 'H2H34H',
}), 'with selected key, values do not matter');

ok($foo->check_selected_option($fif, {
    checked => 1,
    value => 'H2H34H',
}), 'with checked key, values do not matter');

ok($foo->check_selected_option($fif, {
    selected => 1,
    value => $fif,
}), 'with selected key, values do not matter');

ok($foo->check_selected_option($fif, {
    checked => 1,
    value => $fif,
}), 'with checked key, values do not matter');

done_testing;
