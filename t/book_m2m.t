use strict;
use warnings;
use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 10;
}

use_ok( 'HTML::FormHandler' );

use_ok( 'BookDB::Form::BookM2M');

use_ok( 'BookDB::Schema::DB');

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');


my $form = BookDB::Form::BookM2M->new(item_id => undef, schema => $schema);

ok( !$form->validate, 'Empty data' );

$form->clear_state;

# This is munging up the equivalent of param data from a form
my $good = {
    'title' => 'How to Test Perl Form Processors',
    'author' => 'I.M. Author',
    'genres' => [2, 4, 3],
    'isbn'   => '123-02345-0502-2' ,
    'publisher' => 'EreWhon Publishing',
};

ok( $form->validate( $good ), 'Good data' );

ok( $form->update_model, 'Update validated data');

my $book = $form->item;
ok ($book, 'get book object from form');

my $num_genres = $book->genres->count;
is( $num_genres, 3, 'multiple select list updated ok');

my $id = $form->item->id;
$form->clear_state;

$form = BookDB::Form::BookM2M->new( item_id => $id, schema => $schema ); 
my $genres_field = $form->field('genres');
is_deeply( sort $genres_field->value, [2, 3, 4], 'value of multiple field is correct');


# clean up book db & form
$book->delete;


