use strict;
use warnings;
use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 24;
}

use_ok( 'HTML::FormHandler' );

use_ok( 'BookDB::Form::Book');

use_ok( 'BookDB::Schema::DB');

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $book = $schema->resultset('Book')->create(
   {  title => 'Testing form',
      isbn => '02340994',
      author => 'S.Else',
      publisher => 'NoWhere',
      pages => '702',
   });
END { $book->delete }

ok( $book, 'get book');

my $form = BookDB::Form::Book->new(item => $book, schema => $schema);
ok( $form, 'create form from db object');

is( $form->field('pages')->fif, 702, 'get field fif value' );

is( $form->field('author')->fif, 'S.Else', 'get another field fif value' );

my $fif = $form->fif;

is_deeply( $fif, {
      title => 'Testing form',
      isbn => '02340994',
      author => 'S.Else',
      publisher => 'NoWhere',
      pages => '702',
   }, 'get form fif' );

$fif->{pages} = '501';
$form = BookDB::Form::Book->new(item => $book, schema => $schema, params => $fif);
ok( $form, 'use params parameters on new' );

is( $form->field('pages')->fif, 702, 'get field fif value' );

is( $form->get_param('pages'), '501', 'params contains new value' );

is( $form->field('author')->fif, 'S.Else', 'get another field fif value' );

my $validated = $form->validate;

ok( $validated, 'validated without params' );

is( $form->field('author')->fif, 'S.Else', 'get field fif value after validate' );
#ok( !$form->field('author')->has_input, 'no input for field');


$form->clear_state;
ok( !$form->fif, 'clear_state clears fif' );


my $params = {
   title => 'Testing form',
   isbn => '02340234',
   pages => '699',
   author => 'J.Doe',
   publisher => '',
};

$form = BookDB::Form::Book->new(item => $book, schema => $schema, params => $params);

$validated = $form->validate( $params );

ok( $validated, 'validated with params' );

is( $form->field('pages')->fif, 699, 'get field fif after validation' );

is( $form->field('author')->fif, 'J.Doe', 'get field author after validation' );

is_deeply( $form->fif, {
   title => 'Testing form',
   isbn => '02340234',
   pages => '699',
   author => 'J.Doe' }, 'get form fif after validation' );

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'my_compound' => ( type => 'Compound' );
   has_field 'my_compound.one';
   has_field 'my_compound.two';
   has_field 'my_compound.three' => ( type => 'Compound' );
   has_field 'my_compound.three.first';
   has_field 'my_compound.three.second';
}

$form = My::Form->new;
ok( $form, 'get form with compound fields' );
$params = {
   'my_compound.one' => 'What',
   'my_compound.two' => 'Is',
   'my_compound.three.first' => 'Up',
   'my_compound.three.second' => 'With you?'
};
$form->validate($params);
ok($form->validated, 'form validated');
is_deeply($form->fif, $params, 'fif is correct');
$form->clear_fif;
ok( !$form->fif, 'fif is cleared');
