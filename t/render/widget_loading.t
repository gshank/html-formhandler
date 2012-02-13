use strict;
use warnings;
use Test::More;
use Test::Exception;

use lib 't/lib';

{

    package Test::Widgets;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_name_space' => ( default => 'Widget' );

    has_field 'alpha' => ( widget => 'test_widget' );
    has_field 'omega' => ( widget => 'Omega' );
    has_field 'gamma' => ( widget => '+Widget::Field::TestWidget' );
    has_field 'iota';
}

my $form = Test::Widgets->new;
ok( $form, 'get form with custom widgets' );
is( $form->field('alpha')->render, '<p>The test succeeded.</p>', 'alpha rendered ok' );
is( $form->field('omega')->render, '<h1>You got here!</h1>',     'omega rendered ok' );
is( $form->field('gamma')->render, '<p>The test succeeded.</p>', 'alpha rendered ok' );

{

    package Test::NoWidget;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_name_space' => ( default => sub { ['Widget'] } );
    has_field 'no_widget' => ( widget => 'NoWidget' );
}
dies_ok( sub { Test::NoWidget->new }, 'dies on no widget' );
throws_ok( sub { Test::NoWidget->new }, qr/Can't find /, 'no widget throws message' );


done_testing;
