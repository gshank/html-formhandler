use strict;
use warnings;
use Test::More;

BEGIN {
   eval "use GD::SecurityImage";
   plan skip_all => 'GD::SecurityImage required' if $@;
}

use_ok( 'HTML::FormHandler::Field::Captcha' );

{
   package Test::Captcha;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Role::Captcha';
   with 'HTML::FormHandler::Render::Simple';

   has_field 'some_field';
   has_field 'subject';
   has_field '+captcha' => ( id => 'captcha' );

   sub validate_subject {
       my ( $self, $field ) = @_;
       $field->add_error("Incorrect")
           unless $field->value eq 'Correct';
   }

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

my $params = { some_field => 'test', subject => 'Correct', captcha => '1234' };
$form->process( ctx => $ctx, params => $params );
ok( !$form->validated, 'form did not validate with wrong captcha');

my $rnd2 = $ctx->{session}->{captcha}->{rnd};
ok( $rnd ne $rnd2, 'we now have a different captcha');
ok( !$form->field('captcha')->fif, 'no fif for captcha' );
$params->{captcha} = $rnd2;
$params->{subject} = 'Incorrect';
$form->process( ctx => $ctx, params => $params ); 
# valid captcha, invalid subject
ok( !$form->validated, 'form did not validate: valid captcha, invalid field' );
ok( $rnd2 == $ctx->{session}->{captcha}->{rnd}, 'captcha has not changed' ); 

$params->{subject} = 'Correct';
$form->process( ctx => $ctx, params => $params );
ok( $form->validated, 'form validated; old captcha, valid fields' ); 

my $render = $form->render_field('captcha');
is( $render, '
<div class="captcha"><label class="label" for="captcha">Verification: </label><img src="/captcha/test"/><input id="captcha" name="captcha"></div>
', 'captcha renders ok' );


done_testing;

