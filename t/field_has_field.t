use Test::More tests => 5;

use lib 't/lib';

use_ok( 'HTML::FormHandler::Field' );
use_ok( 'HTML::FormHandler::Field::Compound' );
use_ok( 'Field::Address' );

my $field = HTML::FormHandler::Field::Compound->new( name => 'testfield' );
ok( $field, 'get base field object' );

my $field2 = Field::Address->new( name => 'addressfield' );

ok( $field2, 'get subclassed field object' );

