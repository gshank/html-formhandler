use strict;
use warnings;
use Test::More;
use File::ShareDir;

BEGIN {
    plan skip_all => 'Template Toolkit to rest Render::WithTT'
       unless eval { require Template };
}

use_ok('HTML::FormHandler::Render::WithTT');

my $dir = File::ShareDir::dist_dir('HTML-FormHandler') . '/templates/';
ok( $dir, 'found template dir' );

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::WithTT';

    sub build_tt_template { 'form.tt' }
    sub build_tt_include_path { ['share/templates'] }

    has_field 'foo';
    has_field 'bar';
    has_field 'submit' => ( type => 'Submit' );

}

my $form = Test::Form->new;
ok( $form, 'form builds' );
ok( $form->tt_include_path, 'tt include path' );
my $rendered_form = $form->tt_render;
ok($rendered_form, 'form renders' );

done_testing;
