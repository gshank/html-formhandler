use strict;
use warnings;

use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 7;
}

use BookDB::Form::User;
use BookDB::Form::User2;
use BookDB::Form::User3;
use BookDB::Schema::DB;
use BookDB::Form::BookWithOwner;

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
my $user = $schema->resultset('User')->find( 1 );

my $form;
my $options;

$form = BookDB::Form::User->new( item => $user );
is( $form->field( 'birthdate' )->field( 'year' )->fif, 1970, 'Year loaded' );
is( $form->field( 'birthdate' )->field( 'month' )->fif, 4, 'Month loaded' );
is( $form->field( 'birthdate' )->field( 'day' )->fif, 23, 'Day loaded' );

my $fif = $form->fif;
#print Dumper( $form->fif ); use Data::Dumper;

$form = BookDB::Form::User2->new( item => $user );
is( $form->field( 'birthdate' )->field( 'year' )->fif, 1000, 'Year deflated' );
is( $form->field( 'birthdate' )->field( 'month' )->fif, 1, 'Month deflated' );
is( $form->field( 'birthdate' )->field( 'day' )->fif, 5, 'Day deflated' );

$form = BookDB::Form::User3->new( item => $user );
is( $form->field( 'birthdate' )->fif, '1970-04-23', 'DateTime deflated to text' );

