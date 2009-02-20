use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 14;
}

use_ok( 'HTML::FormHandler' );

use_ok( 'BookDB::Form::Author');

use_ok( 'BookDB::Schema::DB');

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $pk = ['J.K.', 'Rowling'];
my $authors = $schema->resultset('Author');
my $author = $schema->resultset('Author')->find( @{$pk} );
ok( $author, 'get author from db' );
is( $author->country, 'U.K.', 'correct value in author');

my $form = BookDB::Form::Author->new(item_id => $pk, schema => $schema);
ok( $form, 'get form with multiple primary key' );
is( $form->item->country, 'U.K.', 'got right row');

my $pk_hashref = { last_name => 'Rowling', first_name => 'J.K.' };
$author = $schema->resultset('Author')->find( $pk_hashref );
ok( $author, 'get author from db with hashref');

$form = BookDB::Form::Author->new(item_id => $pk_hashref, schema => $schema);
ok( $form, 'get form with array of hashref primary key' );
is( $form->item->country, 'U.K.', 'got right row');

my $pk_hashlist = [{ last_name => 'Rowling', first_name => 'J.K.' },
                   { key => 'primary' }];
$author = $schema->resultset('Author')->find( @{$pk_hashlist} );
ok( $author, 'get author from db with hashref');

$form = BookDB::Form::Author->new(item_id => $pk_hashlist, schema => $schema);
ok( $form, 'get form with array of hashref primary key' );
is( $form->item->country, 'U.K.', 'got right row');
