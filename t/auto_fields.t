use Test::More;
use lib 't/lib';

BEGIN { 
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 6;
}

use_ok('HTML::FormHandler::Model::DBIC');

use BookDB::Schema::DB;

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db'); 

ok($schema, 'get schema');

{
   package My::Form;
   use Moose;
   extends 'HTML::FormHandler::Model::DBIC';

   has '+item_class' => ( default => 'Book' );

   sub profile {
      return {
         auto_required => ['title', 'author', 'isbn', 'publisher'],
           auto_optional => ['genres', 'format', 'year', 'pages'], 
      };
   }
}

my $form = My::Form->new( item_id => 1, schema => $schema );
ok( $form, 'get form');


my $title_field = $form->field('title');
my $author_field = $form->field('author');

ok( $title_field->value eq 'Harry Potter and the Order of the Phoenix', 'get title from form');

ok( $title_field->order == 1, 'order for title');

ok( $author_field->order == 2, 'order for author'); 

