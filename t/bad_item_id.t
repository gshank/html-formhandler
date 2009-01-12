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

my $id = 99;
my $record = $schema->resultset('Book')->find($id);
$record->delete if $record;

{
   package My::Form;
   use Moose;
   extends 'HTML::FormHandler::Model::DBIC';

   has '+item_class' => ( default => 'Book' );

   sub profile {
       return {
           fields    => [
               title     => {
                  type => 'Text',
                  required => 1,
               },
               author    => 'Text',
           ],
       };
   }
}

my $form = My::Form->new( item_id => $id, schema => $schema );

ok( $form, 'get form');

my $title_field = $form->field('title');

ok( !$title_field->value, 'did not get title from form');

my $params = {
    'title' => 'How to Test Perl Form Processors',
    'author' => 'I.M. Author',
    'isbn'   => '123-02345-0502-2' ,
    'publisher' => 'EreWhon Publishing',
};

ok( $form->validate( $params ), 'validate data' );

ok( $form->update_model, 'update validated data');

my $book = $form->item;

ok($book->id != 99,'book row ID does not match ID passed in object from form');
$book->delete;

#------------------------
