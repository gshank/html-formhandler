use strict;
use warnings;

use lib './t';
use MyTest
    tests   => 2,
    recommended => ['DateTime'];

use_ok( 'HTML::FormHandler::Field::DateTime' );

my $field = HTML::FormHandler::Field::DateTime->new( name => 'test_field' );

ok( defined $field,  'new() called' );


