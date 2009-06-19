use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 6;
}

use_ok( 'BookDB::Form::Book');
use_ok( 'BookDB::Schema::DB');

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $bad = {
    'title' => "Another Silly Test Book",
    'author' => "C. Foolish",
    'year' => '1590',
    'pages' => 'too few',
};

my $book = $schema->resultset('Book')->create( $bad );
END { $book->delete }

my $form = BookDB::Form::Book->new( item => $book );

ok( !$form->db_validate, 'Bad db data doesn\'t validate' );

$bad->{year} = 1999;
$bad->{pages} = 101;
my $validated = $form->process( $bad );
ok( $validated, 'now form validates' );

$form->update_model;
is( $book->year, 1999, 'book has been updated with correct data' );

