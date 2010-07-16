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
 
ok(!$foo->check_selected_option({ value => '82HJ27' }, $fif),
     'no selected/checked key and diff values');
 
ok($foo->check_selected_option({ value => $fif }, $fif),
     'no selected/checked key and same values');
 
ok(!$foo->check_selected_option({
     selected => 0,
     value => '98HH21',
}, $fif), 'with selected key, values does not matter');
 
ok(!$foo->check_selected_option({
     checked => 0,
     value => '98HH21',
}, $fif), 'with checked key, values does not matter');
 
ok(!$foo->check_selected_option({
     selected => 0,
     value => $fif,
}, $fif), 'with selected key, values does not matter');
 
ok(!$foo->check_selected_option({
     checked => 0,
     value => $fif,
}, $fif), 'with checked key, values does not matter');
 
ok($foo->check_selected_option({
     selected => 1,
     value => 'H2H34H',
}, $fif), 'with selected key, values does not matter');
 
ok($foo->check_selected_option({
     checked => 1,
     value => 'H2H34H',
}, $fif), 'with checked key, values does not matter');
 
ok($foo->check_selected_option({
     selected => 1,
     value => $fif,
}, $fif), 'with selected key, values does not matter');
 
ok($foo->check_selected_option({
     checked => 1,
     value => $fif,
}, $fif), 'with checked key, values does not matter');
 
done_testing;
