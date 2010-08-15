use strict;
use warnings;
use Test::More;

use_ok( 'HTML::FormHandler::Wizard' );

{
    package Test::Wizard;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Wizard';

    has_field 'foo';
    has_field 'bar';
    has_field 'zed';

    has_page 'one' => ( fields => ['foo'] );
    has_page 'two' => ( fields => ['bar'] );
    has_page 'three' => ( fields => ['zed'] );
}

my $wizard = Test::Wizard->new;
ok( $wizard, 'wizard built ok' );
is( $wizard->num_pages, 3, 'right number of pages' );
ok( $wizard->page('one')->has_fields, 'first page has a field' );
is( $wizard->page('one')->field('foo')->name, 'foo', 'field object from page' );

{
    package Test::Wizard::List;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Wizard';

    has_field 'foo';
    has_field 'bar';
    has_field 'zed';

    sub page_list { [
        one => { fields => ['foo'] },
        two => { fields => ['bar'] }, 
        three => { fields => ['zed'] }
    ]}

}

$wizard = Test::Wizard::List->new;
ok( $wizard, 'wizard built ok' );
is( $wizard->num_pages, 3, 'right number of pages' );
ok( $wizard->page('one')->has_fields, 'first page has a field' );
is( $wizard->page('one')->field('foo')->name, 'foo', 'field object from page' );

done_testing;
