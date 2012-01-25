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

my $stash = {};
$wizard = Test::Wizard::List->new( stash => $stash );
ok( $wizard, 'wizard built ok' );
is( $wizard->num_pages, 3, 'right number of pages' );
ok( $wizard->page('one')->has_fields, 'first page has a field' );
is( $wizard->page('one')->field('foo')->name, 'foo', 'field object from page' );

$wizard->process( params => {} );
like( $wizard->render, qr/\<input type="hidden" name="page_num" id="page_num" value="1" \/\>/, 'renders ok' );
is( $wizard->field('page_num')->value, 1, 'wizard is on first page' );

$wizard->process( params => { foo => 'test123', page_num => 1 } );
is( $wizard->field('page_num')->value, 2, 'wizard is on second page' );
like( $wizard->render, qr/\<input type="hidden" name="page_num" id="page_num" value="2" \/\>/, 'renders ok' );
is_deeply( $stash, { foo => 'test123', page_num => 1 }, 'values saved' );

$wizard->process( params => { bar => 'xxxxx', page_num => 2 } );
is( $wizard->field('page_num')->value, 3, 'wizard is on third page' );
like( $wizard->render, qr/\<input type="hidden" name="page_num" id="page_num" value="3" \/\>/, 'renders ok' );
is_deeply( $stash, { foo => 'test123', page_num => 2, bar => 'xxxxx' }, 'values saved' );

$wizard->process( params => { zed => 'omega', page_num => 3 } );
ok( $wizard->validated, 'wizard validated on last page' );
is_deeply( $stash, { foo => 'test123', page_num => 3, bar => 'xxxxx', zed => 'omega' }, 'values saved' );
is_deeply( $wizard->value, { foo => 'test123', page_num => 3, bar => 'xxxxx', zed => 'omega' }, 'value is correct' );

done_testing;
