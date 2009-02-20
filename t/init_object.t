use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 11;
}

use_ok('HTML::FormHandler::Model::DBIC');

use BookDB::Schema::DB;

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db'); 

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Model::DBIC';

   has '+item_class' => ( default => 'Book' );
   has_field 'title' => ( type => 'Text', required => 1 );
   has_field 'author' => ( type => 'Text' );
   sub init_value_author
   {
      'Pick a Better Author'
   }
}

my $init_object = {
    'title' => 'Fill in the title',
    'author' => 'Enter an Author',
};

my $form = My::Form->new( init_object => $init_object, schema => $schema );

ok( $form, 'get form');

my $title_field = $form->field('title');
is( $title_field->value, 'Fill in the title', 'get title from init_object');

my $author_field = $form->field('author');
is( $author_field->value, 'Pick a Better Author', 'get init value from form' );


my $params = {
    'title' => 'We Love to Test Perl Form Processors',
    'author' => 'B.B. Better',
};

ok( $form->validate( $params ), 'validate data' );

ok( $form->update_model, 'update validated data');

my $book = $form->item;
is( $book->title, 'We Love to Test Perl Form Processors', 'title updated');

$book->delete;

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'testform_' );
   has_field 'optname' => ( temp => 'First' );
   has_field 'reqname' => ( required => 1 );
   has_field 'somename';
}


$form = My::Form->new( init_object => {reqname => 'Starting Perl',
                                       optname => 'Over Again' } );
ok( $form, 'non-db form created OK');
is( $form->field('optname')->value, 'Over Again', 'get right value from form');
$form->validate({});
ok( !$form->validated, 'form validated' );
is( $form->field('reqname')->fif, 'Starting Perl', 
                      'get right fif with init_object');
