use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 5;
}

use BookDB::Schema::DB;
use BookDB::Form::Book;

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $form = BookDB::Form::Book->new(schema => $schema);

# set "comment" accessor
my $params = {
    'title' => 'Humpty Dumpty Processors',
    'author' => 'J.M.Smith',
    'isbn'   => '123-92995-0502-2' ,
    'publisher' => 'Somewhere Publishing',
    'comment'   => 'This is a comment',
};

ok( $form->validate( $params ), 'non-column, non-rel accessor validates' );

ok( $form->update_model, 'Update validated data');
END { $form->item->delete }

my $book = $form->item;
ok ($book, 'get book object from form');

is( $book->comment, 'This is a comment', 'get accessor-only data');


