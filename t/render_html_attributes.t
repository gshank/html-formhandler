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

    sub build_tt_template     {'form.tt'}
    sub build_tt_include_path { ['share/templates'] }

    has_field 'foo' => ( css_class => 'schoen', style => 'bunt' );

}

my %results;
{
    my $form
        = Test::Form->new( css_class => 'beautifully', style => 'colorful' );
    HTML::FormHandler::Render::WithTT->meta->apply($form);
    $results{TT} = $form->render;
}
{
    my $form
        = Test::Form->new( css_class => 'beautifully', style => 'colorful' );
    HTML::FormHandler::Render::Simple->meta->apply($form);
    $results{Simple} = $form->render;
}
{
    my $form
        = Test::Form->new( css_class => 'beautifully', style => 'colorful' );
    HTML::FormHandler::Render::Table->meta->apply($form);
    $results{Table} = $form->render;
}
is( scalar( grep {$_} values %results ),
    scalar keys %results,
    'Both methods rendered'
);

while ( my ( $key, $res ) = each %results ) {
    like( $res, qr/class="schoen"/, "$key Field got the class" );
    like( $res, qr/style="bunt"/,   "$key Field got the style" );

    like( $res, qr/class="beautifully"/, "$key Form got the class" );
    like( $res, qr/style="colorful"/,    "$key Form got the style" );
}

done_testing();

