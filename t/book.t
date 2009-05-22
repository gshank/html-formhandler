use strict;
use warnings;
use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 27;
}

use_ok( 'HTML::FormHandler' );

use_ok( 'BookDB::Form::Book');

use_ok( 'BookDB::Schema::DB');

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $form = BookDB::Form::Book->new(schema => $schema);

ok( !$form->process, 'Empty data' );

# This is munging up the equivalent of param data from a form
my $good = {
    'title' => 'How to Test Perl Form Processors',
    'author' => 'I.M. Author',
    'genres' => [2, 4],
    'format'       => 2,
    'isbn'   => '123-02345-0502-2' ,
    'publisher' => 'EreWhon Publishing',
};

ok( $form->process( params => $good ), 'Good data' );

my $book = $form->item;
END { $book->delete };

ok ($book, 'get book object from form');

is_deeply( $form->values, $good, 'values correct' );
is_deeply( $form->fif, $good, 'fif correct' );

my $num_genres = $book->genres->count;
is( $num_genres, 2, 'multiple select list updated ok');

is( $form->field('format')->value, 2, 'get value for format' );

my $id = $book->id;

$good->{author} = '';
$form->process($good);

ok( $form->validated, 'form validated with null author');

ok( $form->field('author')->value_changed, 'init value and value of author are different');
is( $book->author, undef, 'updated author with null value');
is( $form->field('author')->value, undef, 'author value right in form');
is( $form->field('publisher')->value, 'EreWhon Publishing', 'right publisher');

my $value_hash = { %{$good}, 
                   author => undef,
                   comment => undef,
                   year => undef,
                   pages => undef
                 };
is_deeply( $form->values, $value_hash, 'get right values from form');

$_->clear_input for $form->fields;

my $bad_1 = {
    notitle => 'not req',
    silly_field   => 4,
};

ok( !$form->process( $bad_1 ), 'bad 1' );

$form = BookDB::Form::Book->new(item => $book, schema => $schema);
ok( $form, 'create form from db object');

my $genres_field = $form->field('genres');
is_deeply( sort $genres_field->value, [2, 4], 'value of multiple field is correct');

my $bad_2 = {
    'title' => "Another Silly Test Book",
    'author' => "C. Foolish",
    'year' => '1590',
    'pages' => 'too few',
    'format' => '22',
};

ok( !$form->process( $bad_2 ), 'bad 2');
ok( $form->field('year')->has_errors, 'year has error' );
ok( $form->field('pages')->has_errors, 'pages has error' );
ok( !$form->field('author')->has_errors, 'author has no error' );
ok( $form->field('format')->has_errors, 'format has error' );

$form->set_param( year => 1999 );
$form->set_param( pages => 101 );
$form->set_param( format => 2 );
my $validated = $form->validate_form;
ok( $validated, 'now form validates' );

$form->process;
is( $book->publisher, 'EreWhon Publishing', 'publisher has not changed');

