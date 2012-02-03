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
use_ok('HTML::FormHandler::Render::Table');

my $dir = File::ShareDir::dist_dir('HTML-FormHandler') . '/templates/';
ok( $dir, 'found template dir' );

{

    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( css_class => 'schoen', style => 'bunt', title => 'MyTitle' );
    has_field 'bar' => ( element_attr => { arbitrary => 'something', title => 'AltTitle' } );

}

{
    package Test::Form::WithTT::Role;
    use Moose::Role;
    with 'HTML::FormHandler::Render::WithTT' =>
        { -excludes => [ 'build_tt_template', 'build_tt_include_path' ] };
    sub build_tt_template     {'form/form.tt'}
    sub build_tt_include_path { ['share/templates'] }
}

my %results;
{
    my $form
        = Test::Form->new( css_class => 'beautifully', style => 'colorful' );
    $results{Widgets} = $form->render;
}
{
    my $form
        = Test::Form->new_with_traits( traits => ['Test::Form::WithTT::Role'],
            css_class => 'beautifully', style => 'colorful' );
    $results{TT} = $form->tt_render;
}
{
    my $form
        = Test::Form->new_with_traits( traits => ['HTML::FormHandler::Render::Simple'],
            css_class => 'beautifully', style => 'colorful' );
    $results{Simple} = $form->render;
}
{
    my $form
        = Test::Form->new_with_traits( traits => ['HTML::FormHandler::Render::Table'],
            css_class => 'beautifully', style => 'colorful' );
    $results{Table} = $form->render;
}
is( scalar( grep {$_} values %results ),
    scalar keys %results,
    'Both methods rendered'
);

while ( my ( $key, $res ) = each %results ) {
    like( $res, qr/class="schoen"/, "$key Field got the class (schoen)" );
    like( $res, qr/style="bunt"/,   "$key Field got the style (bunt)" );

    like( $res, qr/class="beautifully"/, "$key Form got the class (beautifully)" );
    like( $res, qr/style="colorful"/,    "$key Form got the style (colorful)" );

    like( $res, qr/arbitrary="something"/,   "$key Field got the arbitrary attribute" );

    like( $res, qr/title="MyTitle"/,   "$key Field got the title" );
    like( $res, qr/title="AltTitle"/,   "$key Field got the title from element_attr" );

}

done_testing();

