use strict;
use warnings;

use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 7;
}

use_ok( 'BookDB::Form::User');
use_ok( 'BookDB::Schema::DB');

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $user = $schema->resultset('User')->find( 1 );

my $form = BookDB::Form::User->new( item => $user );
ok( $form, 'User form created' );
my $options = $form->field( 'country' )->options;
is( @$options, 12, 'Options loaded from the model' );

$form = BookDB::Form::User->new( schema => $schema, source_name => 'User' );
ok( $form, 'User form created' );
$options = $form->field( 'country' )->options;
is( @$options, 12, 'Options loaded from the model' );
#warn Dumper( $options ); use Data::Dumper;

