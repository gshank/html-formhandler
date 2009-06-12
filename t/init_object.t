use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 18;
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
   has_field 'user_updated' => ( type => 'Hidden', writeonly => 1, value => 1 );
   has_field 'publisher' => ( noupdate => 1 );
   sub init_value_author
   {
      'Pick a Better Author'
   }
}

my $init_object = {
    'title' => 'Fill in the title',
    'author' => 'Enter an Author',
    'user_updated' => 'nope',
    'publisher' => 'something',
};

my $form = My::Form->new( init_object => $init_object, schema => $schema );

ok( $form, 'get form');

my $title_field = $form->field('title');
is( $title_field->value, 'Fill in the title', 'get title from init_object');

my $author_field = $form->field('author');
is( $author_field->value, 'Pick a Better Author', 'get init value from form' );

is( $form->field('user_updated')->value, 1, 'writeonly value not from init_obj' );
is( $form->field('publisher')->fif, 'something', 'noupdate fif from init_obj' );

my $params = {
    'title' => 'We Love to Test Perl Form Processors',
    'author' => 'B.B. Better',
    'publisher' => 'anything',
};

ok( $form->process( $params ), 'validate data' );
ok( $form->field('title')->value_changed, 'init_value ne value');
is( $form->field('user_updated')->value, 1, 'writeonly field has value' );
is( $form->field('publisher')->value, 'anything', 'value for noupdate field' );
my $values = $form->value;
ok( !exists $values->{publisher}, 'no publisher in values' );

ok( $form->update_model, 'update validated data');

my $book = $form->item;
is( $book->title, 'We Love to Test Perl Form Processors', 'title updated');
is( $book->publisher, undef, 'no publisher' );

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
$form->process({});
ok( !$form->validated, 'form validated' );
is( $form->field('reqname')->fif, 'Starting Perl', 
                      'get right fif with init_object');
