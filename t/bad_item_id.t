use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 10;
}

use_ok('HTML::FormHandler::Model::DBIC');

use BookDB::Schema::DB;

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db'); 

my $id = 99;
my $record = $schema->resultset('Book')->find($id);
$record->delete if $record;

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Model::DBIC';

   has '+item_class' => ( default => 'Book' );

   has_field 'title' => ( type => 'Text', required => 1 );
   has_field 'author';
   no HTML::FormHandler::Moose;
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
END { $book->delete }

ok($book->id != 99,'book row ID does not match ID passed in object from form');

is( $book->publisher, undef, 'No publisher, because no field');

# make sure that primary keys included by error do not update
{
   package My::Form2;
   use HTML::FormHandler::Moose;
   extends 'My::Form';

   has_field 'id' => ( type => 'Integer' );

   no HTML::FormHandler::Moose;
}

$id = $book->id;
$form = My::Form2->new( $book );
ok( $form, 'get form for Form2' );

$form->update( params => { title => 'How to Test, Volume 2' } );

is( $book->title, 'How to Test, Volume 2', 'get new title');

is( $book->id, $id, 'id is correct' );
