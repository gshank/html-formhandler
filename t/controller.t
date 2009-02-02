use strict;
use warnings;

use Test::More;
use lib 't/lib';

BEGIN {
   eval "use Catalyst";
   plan skip_all => 'Catalyst required' if $@;
   eval "use Catalyst::Component::InstancePerContext";
   plan skip_all => 'Catalyst::Component::InstancePerContext required' if $@;
   eval "use Test::WWW::Mechanize::Catalyst";
   plan skip_all => 'Test::WWW::Mechanize::Catalyst required' if $@;
   eval "use Template";
   plan skip_all => 'Template required' if $@;
   eval "use Email::Valid";
   plan skip_all => 'Email::Valid required' if $@;
   plan tests => 5;
}

use Test::WWW::Mechanize::Catalyst 'BookDB';

my $mech = Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok("/book/list");
$mech->content_contains('Harry Potter', 'list contents');

$mech->get_ok('http://localhost/book/edit/1');

$mech->content_contains('Harry', 'get Harry Potter');

$mech->content_contains('Boomsbury', 'get publisher');
