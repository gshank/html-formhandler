use strict;
use warnings;
use Test::More;
use Test::Warn;
use lib 't/lib';

BEGIN {
   plan skip_all => 'Set HFH_DUMP_TEST to run this test'
      unless $ENV{HFH_DUMP_TEST};
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 7;
}

use_ok( 'HTML::FormHandler' );

use_ok( 'BookDB::Form::Book');

use_ok( 'BookDB::Schema::DB');

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $form = BookDB::Form::Book->new(verbose => 1);

ok( $form, 'get form object with verbose output' );

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
END {
  $book->delete;
} 

ok( $form->item, 'get new book object' );

