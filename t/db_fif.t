use strict;
use warnings;

use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 3;
}

use BookDB::Form::User;
use BookDB::Schema::DB;
use BookDB::Form::BookWithOwner;

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
my $user = $schema->resultset('User')->find( 1 );

my $form;
my $options;

$form = BookDB::Form::User->new( item => $user );
my $fif = $form->fif;
is( $form->field( 'birthdate' )->field( 'year' )->fif, 1970, 'Year loaded' );
is( $form->field( 'birthdate' )->field( 'month' )->fif, 4, 'Month loaded' );
is( $form->field( 'birthdate' )->field( 'day' )->fif, 23, 'Day loaded' );

print Dumper( $form->fif ); use Data::Dumper;

