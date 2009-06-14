use strict;
use warnings;
use Test::More;

BEGIN {
   eval "use GD::SecurityImage";
   plan skip_all => 'GD::SecurityImage required' if $@;
   plan tests => 9;
}

use_ok( 'HTML::FormHandler::Field::Captcha' );

{
   package Test::Captcha;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Role::Captcha';
   with 'HTML::FormHandler::Render::Simple';

   has_field 'some_field' => (order => 1);
   has_field 'subject' => (order => 2);
   has_field '+captcha' => ( id => 'captcha' );

}

{
   package Mock::Ctx;
   use Moose;
   has 'session' => ( isa => 'HashRef', is => 'rw' );
}

my $ctx = Mock::Ctx->new;
ok( $ctx, 'get mock ctx' );

my $form = Test::Captcha->new( ctx => $ctx );
ok( $form, 'get form' );
my $rnd = $ctx->{session}->{captcha}->{rnd};
ok( $rnd, 'captcha is in session' );

$form->process( ctx => $ctx, params => { some_field => 'test', subject => 'Testing captcha', captcha => '1234' } );
ok( !$form->validated, 'form did not validate with wrong captcha');

my $rnd2 = $ctx->{session}->{captcha}->{rnd};
ok( $rnd ne $rnd2, 'we now have a different captcha');
ok( !$form->field('captcha')->fif, 'no fif for captcha' );
$form->process( ctx => $ctx, params => { some_field => 'test', subject => 'Testing captcha', captcha => $rnd2 } );
ok( $form->validated, 'form validated' );

my $render = $form->render_field('captcha');
is( $render, '
<div class="captcha ><label class="label" for="captcha">Verification: </label><img src="/captcha/test"/><input id="captcha" name="captcha"></div>
', 'captcha renders ok' );
