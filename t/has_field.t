use Test::More tests => 10;

use lib 't/lib';

use_ok( 'HTML::FormHandler' );

use_ok( 'Form::Two' );

my $form = Form::Two->new;

ok( $form, 'get subclassed form' );

is( $form->field('optname')->temp, 'Txxt', 'new field');

ok( $form->field('reqname'), 'get old field' );

ok( $form->field('fruit'), 'fruit field' );

use_ok( 'Form::Test' );

$form = Form::Test->new;

ok( $form, 'get base form' );
ok( !$form->field_exists('new_field'), 'no new field');
ok( $form->field_exists('optname'), 'base field exists');
