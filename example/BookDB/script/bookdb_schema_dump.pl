#!/usr/bin/perl 

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

=head1 NAME

    bookdb_schema_dump.pl

=head1 DESCRIPTION

    Dumps the schema in the database to lib/BookDB/Schema/SchemaDump

=head1 SYNOPSIS

   script/bookdb_schema_dump.pl

=cut

use DBIx::Class::Schema::Loader ('make_schema_at');

make_schema_at(
   'BookDB::Schema::SchemaDump',
   { debug => 1, 
	 dump_directory => "$FindBin::Bin/../lib" },
   [ 'dbi:SQLite:db/book.db' ],
  ); 
