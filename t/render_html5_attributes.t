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
    has '+is_html5' => (default => 1);

    has_field 'foo' => ( css_class => 'schoen', style => 'bunt', title => 'MyTitle', required => 1, maxlength=> 10 );
    has_field 'bar' => ( html_attr => { arbitrary => 'something', title => 'AltTitle' } );
    has_field 'range' => ( type => "Integer", range_start => 5, range_end => 10 );
    has_field 'email' => ( type => "Email");
    has_field 'date' => ( type => "Date");
    has_field 'money' => ( type => "Money");
}

my %results;
{
    my $form
        = Test::Form->new( css_class => 'beautifully', style => 'colorful' );
    $results{Widgets} = $form->render;
}
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

    like( $res, qr/arbitrary="something"/,   "$key Field got the arbitrary attribute" );

    like( $res, qr/title="MyTitle"/,   "$key Field got the title" );
    like( $res, qr/title="AltTitle"/,   "$key Field got the title from html_attr" );

    like( $res, qr/required="required"/,    "$key Form got the html5 required" );
    like( $res, qr/input type="number" name="money"/,    "$key Form got the html5 type" );
    like( $res, qr/input type="date" name="date"/,    "$key Form got the html5 type" );
    like( $res, qr/input type="email" name="email"/,    "$key Form got the html5 type" );
    like( $res, qr/input type="number" name="range"/,    "$key Form got the html5 type" );
    like( $res, qr/max="10"/,    "$key Form got the html5 max attribute" );
    like( $res, qr/min="5"/,    "$key Form got the html5 min attribute" );

}

done_testing();
