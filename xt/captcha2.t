use strict;
use warnings;

use lib 'xt/lib/';

# HFH::TraitFor::Captcha and HFH::Field::Captcha do not work with current
# versions of Catalyst.
#
# The reason seems to be that get_captcha and set_captcha use
# $form->ctx->{session} directly, instead of using the accessor
# $from->ctx->session.
#
# I am not sure if this works with older versions of Catalyst, but it is
# definitely broken when using Catalyst 5.90007
#
# I have attached a simple test.
#
# The patch makes get_captcha and set_captcha using the session-accessor
# IF $form->ctx has one. (if it is a catalyst context). Otherwise, the old
# behaviour will not change. The module should still work with
# non-catalyst applications.

use Test::More;
my @missing;
eval" use Test::WWW::Mechanize::Catalyst; ";
if($@){
    push @missing, "Test::WWW::Mechanize";
}
eval" use GD::SecurityImage; ";
if($@){
    push @missing, "GD::SecurityImage";
}

if(@missing){
plan skip_all => "The following Modules are required to run this test: " . join ", ", @missing;
}
else{
plan tests => 7;
}
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => "MyCatalystApp");

$mech->get_ok("/captcha");
#diag explain $mech;

$mech->content_contains('<img src="/captcha/image"/><input id="captcha" name="captcha"/>');

$mech->get_ok("/captcha/get_rnd");

my $rnd = $mech->content;

$mech->get_ok("/captcha/image");

is $mech->res->content_type, "image/png";

$mech->get_ok("/captcha?captcha=$rnd");

$mech->content_is("verification succeeded");

done_testing;
exit;

