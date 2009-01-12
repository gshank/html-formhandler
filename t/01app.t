use Test::More tests => 5;

use_ok( 'HTML::FormHandler::Model' );
use_ok( 'HTML::FormHandler' );
use_ok( 'HTML::FormHandler::Field' );

use_ok( 'HTML::FormHandler::Model::CDBI' );

SKIP:
{
   eval 'use DBIx::Class';
   skip( 'DBIx::Class required for HTML::FormHandler::Model::DBIC', 1 ) if $@;
   use_ok( 'HTML::FormHandler::Model::DBIC' );
}

