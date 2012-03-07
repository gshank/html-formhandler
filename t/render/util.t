use strict;
use warnings;
use Test::More;

use HTML::FormHandler::Render::Util ('ucc_widget', 'cc_widget');

my @cc = ('MyApp', 'myApp', 'My_App', 'MyLongerApp');
my @ucc = ('my_app', 'my_app', 'my_app', 'my_longer_app');
my @cc_ucc = ('MyApp', 'MyApp', 'MyApp', 'MyLongerApp');

my $index = 0;
foreach my $str ( @cc ) {
    is( ucc_widget($str), $ucc[$index], "$str uncamelcased ok" );
    $index++;
}

$index = 0;
foreach my $str ( @ucc ) {
    is( cc_widget($str), $cc_ucc[$index], "$str camelcased ok" );
    $index++;
}

done_testing;
