use strict;
use warnings;

use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 10;
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

my $birthdate = $user->birthdate; 

my $db_fif = {
   'addresses.0.address_id' => 1,
   'addresses.0.city' => 'Middle City',
   'addresses.0.country' => 'GK',
   'addresses.0.street' => '101 Main St',
   'addresses.1.address_id' => 2,
   'addresses.1.city' => 'DownTown',
   'addresses.1.country' => 'UT',
   'addresses.1.street' => '99 Elm St',
   'addresses.2.address_id' => 3,
   'addresses.2.city' => 'Santa Lola',
   'addresses.2.country' => 'GF',
   'addresses.2.street' => '1023 Side Ave',
   'birthdate.day' => 23,
   'birthdate.month' => 4,
   'birthdate.year' => 1970,
   'country' => 'US',
   'fav_book' => 'Necronomicon',
   'fav_cat' => 'Sci-Fi',
   'license' => 3,
   'occupation' => 'management',
   'opt_in' => 0,
   'user_name' => 'jdoe'
};

my $fif = $form->fif;
is_deeply( $db_fif, $fif, 'get right fif from db');
is( $form->field('opt_in')->fif, 0, 'right value for field with 0');
is( $form->field('license')->fif, 3, 'right value for license field');

#print Dumper( $form->fif ); use Data::Dumper;

$form = BookDB::Form::User2->new( item => $user );
is( $form->field( 'birthdate' )->field( 'year' )->fif, 1000, 'Year deflated' );
is( $form->field( 'birthdate' )->field( 'month' )->fif, 1, 'Month deflated' );
is( $form->field( 'birthdate' )->field( 'day' )->fif, 5, 'Day deflated' );

$form = BookDB::Form::User3->new( item => $user );
is( $form->field( 'birthdate' )->fif, '1970-04-23', 'DateTime deflated to text' );

