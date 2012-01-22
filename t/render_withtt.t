use strict;
use warnings;
use Test::More;
use File::ShareDir;
use HTML::TreeBuilder;

BEGIN {
    plan skip_all => 'Install Template Toolkit to test Render::WithTT'
       unless eval { require Template };
}

use_ok('HTML::FormHandler::Render::WithTT');
use_ok('HTML::FormHandler::Render::Simple');

my $dir = File::ShareDir::dist_dir('HTML-FormHandler') . '/templates/';
ok( $dir, 'found template dir' );

{
    package Test::Form::WithTT::Role;
    use Moose::Role;
    with 'HTML::FormHandler::Render::WithTT' =>
        { -excludes => [ 'build_tt_template', 'build_tt_include_path' ] };
    sub build_tt_template     {'form/form.tt'}
    sub build_tt_include_path { ['share/templates'] }
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has 'auto_fieldset' => ( is => 'rw', default => 0 );
    has_field 'submit' => ( type => 'Submit' );
    has_field 'foo';
    has_field 'bar';
    has_field 'fubar' => ( type => 'Compound' );
    has_field 'fubar.name';
    has_field 'fubar.country';
    has_field 'opt_in' => ( type => 'Checkbox' );
    has_field 'choose' => ( type => 'Select', default => 2 );
    has_field 'picksome' => ( type => 'Multiple', default => [1,2] );
    has_field 'click' => ( type => 'Button' );
    has_field 'reset' => ( type => 'Reset' );
    has_field 'hidden' => ( type => 'Hidden' );
    has_field 'mememe' => ( type => 'Multiple', widget => 'radio_group' );
    has_field 'notes' => ( type => 'TextArea', cols => 30, rows => 4 );
    has_field 'addresses' => ( type => 'Repeatable' );
    has_field 'addresses.street' => ( type => 'Text' );
    has_field 'addresses.city' => ( type => 'Text' );
    has_field 'pw' => ( type => 'Password' );

    sub options_choose {
        return (
            1   => 'apples',
            2   => 'oranges',
            3   => 'kiwi',
        );
    }

    sub options_picksome {
        return (
            1   => 'blue',
            2   => 'red',
            3   => 'orange',
        );
    }
    sub options_mememe {
        return (
            1   => 'me',
            2   => 'my',
            3   => 'mine',
        );
    }
}

my $rendered_via_tt;
{
    my $form = Test::Form->new_with_traits( traits => ['Test::Form::WithTT::Role'], name => 'test_tt' );
    ok( $form, 'form builds' );
    ok( $form->tt_include_path, 'tt include path' );
    $rendered_via_tt = $form->tt_render;
    ok($rendered_via_tt, 'form tt renders' );
}

my $rendered_via_widget;
{
    my $form = Test::Form->new(name => 'test_tt');
    ok( $form, 'form builds' );
    $rendered_via_widget = $form->render;
    ok($rendered_via_widget, 'form simple renders' );
}

my $widget = HTML::TreeBuilder->new_from_content($rendered_via_widget);
my $tt = HTML::TreeBuilder->new_from_content($rendered_via_tt);
is( $tt->as_HTML, $widget->as_HTML,
    "TT Rendering and Widget Rendering matches");

done_testing;
