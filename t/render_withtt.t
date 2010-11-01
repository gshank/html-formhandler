use strict;
use warnings;
use Test::More;
use File::ShareDir;

BEGIN {
    plan skip_all => 'Install Template Toolkit to test Render::WithTT'
       unless eval { require Template };
}

use_ok('HTML::FormHandler::Render::WithTT');
use_ok('HTML::FormHandler::Render::Simple');

my $dir = File::ShareDir::dist_dir('HTML-FormHandler') . '/templates/';
ok( $dir, 'found template dir' );

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    #with 'HTML::FormHandler::Render::WithTT';

    sub build_tt_template { 'form.tt' }
    sub build_tt_include_path { ['share/templates'] }

    has_field 'foo';
    has_field 'bar';
    has_field 'submit' => ( type => 'Submit' );

}

my $rendered_via_tt;
{
    my $form = Test::Form->new(name => 'test_tt');
    HTML::FormHandler::Render::WithTT->meta->apply($form);
    ok( $form, 'form builds' );
    ok( $form->tt_include_path, 'tt include path' );
    $rendered_via_tt = $form->tt_render;
    ok($rendered_via_tt, 'form tt renders' );
}

SKIP: {
    skip 'Install HTML::TreeBuilder to test TT Result', 3
        unless eval { require HTML::TreeBuilder && $HTML::TreeBuilder::VERSION >= 3.23 };
        # really old TreeBuilder versions might not work

    my $rendered_via_widget;
    {
        my $form = Test::Form->new(name => 'test_tt');
        HTML::FormHandler::Render::Simple->meta->apply($form);
        ok( $form, 'form builds' );
        $rendered_via_widget = $form->render;
        ok($rendered_via_widget, 'form simple renders' );
    }

    my $widget = HTML::TreeBuilder->new_from_content($rendered_via_widget);
    my $tt = HTML::TreeBuilder->new_from_content($rendered_via_tt);
    is($widget->as_HTML, $tt->as_HTML,
        "TT Rendering and Widget Rendering matches");
};

done_testing;
