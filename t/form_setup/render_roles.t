use strict;
use warnings;
use Test::More;

{
    package Test::Render;
    use Moose::Role;

    sub render { "This is the rendering role" }
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'Test::Render';

    has_field 'foo';
    has_field 'bar';
}

my $form = Test::Form->new;
my $render = $form->render;
is( $render, "This is the rendering role", 'rendered using role' );

done_testing;
