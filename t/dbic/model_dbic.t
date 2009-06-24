use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 19;
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
   has '+field_list' => ( default => sub {
         [
            book_title   => {
               type => 'Text',
               required => 1,
               accessor => 'title',
            },
            author    => 'Text',
            extra     => 'Text',
         ]
      }
   );
}

my $form = My::Form->new( item_id => 1, schema => $schema );
ok( $form, 'get form');
my $title_field = $form->field('book_title');
my $author_field = $form->field('author');

ok( $title_field->value eq 'Harry Potter and the Order of the Phoenix', 'get title from form');

ok( $title_field->order == 1, 'order for title');

ok( $author_field->order == 2, 'order for author'); 


{
   package My::Form2;
   use Moose;
   extends 'HTML::FormHandler::Model::DBIC';

   has '+field_list' => ( default => sub {
         [
            title     => {
               type => 'Text',
            },
            author    => 'Text',
            extra     => 'Text',
         ]
      }
   );
}

my $book = $schema->resultset('Book')->find(1);

my $form2 = My::Form2->new(item => $book );
ok( $form2, 'get form with row object');
is( $form2->field('title')->value, 'Harry Potter and the Order of the Phoenix', 'get title from form');
is( $form2->item_id, 1, 'item_id set from row');

my $book3 = $schema->resultset('Book')->new_result({});
END { $book3->delete }
my $form3 = My::Form2->new( item => $book3 );
ok( $form3, 'get form from empty row object');
is( $form3->item_id, undef, 'empty row form has no item_id');
is( $form3->item_class, 'Book', 'item_class set from empty row');

$form3->process(params => {});
ok( !$form3->validated, 'empty form does not validate');

$form3->process(params => { extra => 'testing'});
ok( $form3->validated, 'form with single non-db param validates');

my $params = {
   title => 'Testing a form created from an empty row',
   author => 'S.Else',
   extra => 'extra_test'
};

$form3->process( params => $params );
is( $book3->author, 'S.Else', 'row object updated');
is( $form3->field('extra')->value, 'extra_test', 'value of non-db field');
ok( $form3->item->id, 'get id from new result');
ok( $form3->item_id, 'item_id has been set');
$form3->process( params => $params );
ok( $form3->validated, 'form processed a second time');
