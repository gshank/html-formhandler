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

{

    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+is_html5' => (default => 1);

    has_field 'foo' => ( css_class => 'schoen', style => 'bunt', title => 'MyTitle', required => 1, maxlength=> 10 );
    has_field 'bar' => ( html_attr => { arbitrary => 'something', title => 'AltTitle' } );
    has_field 'range' => ( type => "Integer", range_start => 5, range_end => 10 );
    has_field 'email' => ( type => "Email");
    has_field 'date' => ( type => "Date");
    has_field 'money' => ( type => "Money");
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
