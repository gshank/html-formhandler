use strict;
use warnings;

use Test::More tests => 5;

use lib 't/lib';

use Test::WWW::Mechanize::Catalyst 'BookDB';

my $mech = Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok("/book/list");
$mech->content_contains('Harry Potter', 'list contents');

$mech->get_ok('http://localhost/book/edit/1');

$mech->content_contains('Harry', 'get Harry Potter');

$mech->content_contains('Boomsbury', 'get publisher');
