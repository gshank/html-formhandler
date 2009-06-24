use strict;
use warnings;

use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 13;
}

use_ok( 'BookDB::Form::User');
use_ok( 'BookDB::Schema::DB');
use_ok( 'BookDB::Form::BookWithOwner' );

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $user = $schema->resultset('User')->find( 1 );

my $form;
my $options;

$form = BookDB::Form::User->new( item => $user );
ok( $form, 'User form created' );
$options = $form->field( 'country' )->options;
is( @$options, 16, 'Options loaded from the model' );

my $fif = $form->fif;
$fif->{country} = 'PL';
# update user with new country
$form->process($fif);
is( $form->item->country_iso, 'PL', 'country updated correctly');
$fif->{country} = 'US';  # change back
$form->process($fif);

$form = BookDB::Form::User->new( schema => $schema, source_name => 'User' );
ok( $form, 'User form created' );
$options = $form->field( 'country' )->options;
is( @$options, 16, 'Options loaded from the model - simple' );

#warn Dumper( $options ); use Data::Dumper;

$form = BookDB::Form::BookWithOwner->new( schema => $schema, source_name => 'Book' );
ok( $form, 'Book with Owner form created' );
$options = $form->field( 'owner' )->field(  'country' )->options;
is( @$options, 16, 'Options loaded from the model - recursive' );

my $book = $schema->resultset('Book')->find(1);
$form = BookDB::Form::BookWithOwner->new( item => $book );
ok( $form, 'Book with Owner form created' );
$options = $form->field( 'owner' )->field(  'country' )->options;
is( $form->field( 'owner' )->field(  'country' )->value, 'GB', 'Select value loaded in a related record');

