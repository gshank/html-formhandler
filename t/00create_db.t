use strict;
use warnings;
use Test::More tests => 1;
use Path::Class;

my $db_file = file( qw/ t db book.db / );
my $sql_file = file( qw/ t db bookdb.sql / );

unlink $db_file or die "Cannot delete old database: $!";

system 'sqlite3', '-init', $sql_file, $db_file, '.q';

ok( -f $db_file, 'DB generated' );

