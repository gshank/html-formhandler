use strict;
use warnings;
use Test::More;

use_ok('HTML::FormHandler::Render::WithTT');

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::WithTT';

    has_field 'foo';
    has_field 'bar';

}

my $form = Test::Form->new;
ok( $form, 'form builds' );

done_testing;
