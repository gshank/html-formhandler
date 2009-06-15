use strict;
use warnings;

use lib './t';
use lib 't/lib';
use BookDB::Schema::DB;
use MyTest
    tests   => 3,
    recommended => ['DBIx::Class', 'DateTime'];

use_ok( 'HTML::FormHandler::Field::DateTime' );

my $field = HTML::FormHandler::Field::DateTime->new( name => 'test_field' );

ok( defined $field,  'new() called' );

{ 
   package UserForm;
   
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Model::DBIC';
   with 'HTML::FormHandler::Render::Simple';
   
   has_field 'birthdate' => ( type => 'DateTime' ); 
   has_field 'birthdate.year' => ( type => 'Year' );
}

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');

my $user = $schema->resultset( 'User' )->first;
my $form = UserForm->new( item => $user );
ok( $form, 'Form with DateTime field loaded from the db' );
   

