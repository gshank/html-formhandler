use Test::More;

use lib 't/lib';

use_ok( 'HTML::FormHandler' );

use_ok( 'Form::Two' );
my $form = Form::Two->new;
ok( $form, 'get subclassed form' );
is( $form->field('optname')->temp, 'Txxt', 'field new attribute');
ok( $form->field('reqname'), 'get old field' );
is( $form->field('reqname')->temp, 'Abc', 'new attribute' );
is( $form->field('reqname')->required, 1, 'old attribute');
ok( $form->field('fruit'), 'fruit field' );

use_ok( 'Form::Test' );
$form = Form::Test->new;
ok( $form, 'get base form' );
ok( !$form->field('new_field'), 'no new field');
ok( $form->field('optname'), 'base field exists');

# forms with multiple inheritance
use_ok( 'Form::Multiple' );
$form = Form::Multiple->new;
ok( $form, 'create multiple inheritance form' );
ok( $form->field('city'), 'field from superclass exists' );
ok( $form->field('telephone'), 'field from other superclass exists' );

# forms with roles
use_ok( 'Form::MultipleRole');
$form = Form::MultipleRole->new;
ok( $form, 'get form with roles' );
ok( $form->field('street'), 'field from Address role' );
ok( $form->field('email'), 'field from Person role' );

done_testing;
