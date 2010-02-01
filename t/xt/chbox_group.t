use strict;
use warnings;
use Test::More;

use_ok('HTML::FormHandler::Widget::Field::CheckboxGroup');

{
    package Test::CheckboxGroup;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo_list' => ( type => 'Multiple', widget => 'CheckboxGroup' );

    sub options_foo_list {
        [
           1 => 'ShamWow',
           2 => 'SliderStation',
           3 => 'SlapChop',
           4 => 'Zorbeez',
           5 => 'OrangeGlow',
       ]
    }
}

my $form = Test::CheckboxGroup->new;
ok( $form, 'form builds' );
$form->process( { foo_list => [ 2, 4 ] } );
ok( $form->validated, 'form validates' );
my $rendered = $form->field('foo_list')->render;
ok( $rendered, 'field renders' );
my $rendered_form = $form->render;
ok( $rendered_form, 'form renders' );

done_testing;
