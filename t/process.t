use strict;
use warnings;
use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 19;
}

use_ok( 'HTML::FormHandler' );

use_ok( 'BookDB::Form::Book');

use_ok( 'BookDB::Schema::DB');

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $form = BookDB::Form::Book->new;

ok( $form, 'no param new' );

$form->process( item_id => 1, schema => $schema, params => {} );
is( $form->item->id, 1, 'get item from item_id and schema');

ok( !$form->process( schema => $schema ), 'Empty data' );

# This is munging up the equivalent of param data from a form
my $good = {
    'title' => 'How to Test Perl Form Processors',
    'author' => 'I.M. Author',
    'genres' => [2, 4],
    'format'       => 2,
    'isbn'   => '123-02345-0502-2' ,
    'publisher' => 'EreWhon Publishing',
};

ok( $form->process( schema => $schema, params => $good ), 'Good data' );

my $book = $form->item;
END { $book->delete };

ok ($book, 'get book object from form');

my $num_genres = $book->genres->count;
is( $num_genres, 2, 'multiple select list updated ok');

is( $form->value('format'), 2, 'get value for format' );

my $id = $book->id;

my $bad_1 = {
    notitle => 'not req',
    silly_field   => 4,
};

ok( !$form->process( schema => $schema, params => $bad_1 ), 'bad 1' );


my $bad_2 = {
    'title' => "Another Silly Test Book",
    'author' => "C. Foolish",
    'year' => '1590',
    'pages' => 'too few',
    'format' => '22',
};

ok( !$form->process( schema => $schema, params => $bad_2 ), 'bad 2');

ok( $form->field('year')->has_errors, 'year has error' );

ok( $form->field('pages')->has_errors, 'pages has error' );

ok( !$form->field('author')->has_errors, 'author has no error' );

ok( $form->field('format')->has_errors, 'format has error' );


$form->process(item => $book, schema => $schema);
ok( $form, 'create form from db object');

my $genres_field = $form->field('genres');
is_deeply( sort $genres_field->value, [2, 4], 'value of multiple field is correct');

