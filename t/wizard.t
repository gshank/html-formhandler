use strict;
use warnings;
use Test::More;

use_ok( 'HTML::FormHandler::Wizard' );

{
    package Test::Wizard;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar';
    has_field 'zed';

    has_page 'one' => ( fields => ['foo'] );
    has_page 'two' => ( fields => ['bar'] );
    has_page 'three' => ( fields => ['zed'] );
}

my $wizard = Test::Wizard->new;
ok( $wizard, 'wizard built ok' );

done_testing;
