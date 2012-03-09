use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = HTML::FormHandler::I18N->get_handle('en_en');

{
    package MyApp::Form::Password;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    use HTML::FormHandler::Types ('NotAllDigits');

    has '+name' => ( default => 'testform' );
    has '+widget_wrapper' => ( default => 'Bootstrap' );

    # Email & compound definition in form:
    has_field 'email' => (
         type      => 'Email',
         label     => 'Register.Email',
         element_attr => { placeholder => 'Register.Email', class => 'span3', },
         wrapper_attr => { class => 'clearfix' },
         required => 1,
    );
    has_field 'password' => (
         type       => 'Compound',
         required   => 1,
         do_wrapper => 1,
         do_label   => 1,
         label      => 'Register.Password',
    );
    has_field 'password.password' => (
        type       => 'Password',
        do_wrapper => 0,
        do_label   => 0,
        element_attr  => { placeholder => 'Register.Password', class => 'span2', },
        required   => 1,
        minlength  => 5,
        apply => [NotAllDigits],
    );
    has_field 'password.again' => (
        type           => 'PasswordConf',
        password_field => 'password',
        do_wrapper     => 0,
        do_label       => 0,
        element_attr      => { placeholder => 'Register.PasswordAgain', class => 'span2', },
    );

}

my $form = MyApp::Form::Password->new;
ok( $form, 'form built' );
$form->process( params => { email => 'joe@nowhere.com', 'password.password' => '12345', 'password.again' => '54321' } );

my $rendered = $form->render;
my $expected =
'<form id="testform" method="post">
<div class="form_messages">
</div>
<div class="control-group clearfix">
    <label class="control-label" for="email">Register.Email</label>
    <div class="controls">
    <input type="text" name="email" id="email" value="joe@nowhere.com" class="span3" placeholder="Register.Email" /></div>
</div>
<div class="control-group error">
    <label class="control-label" for="password">Register.Password</label>
    <div class="controls">
    <input type="password" name="password.password" id="password.password" value="" class="span2 error" placeholder="Register.Password" />
    <span class="help-inline">Must not be all digits</span>
    <input type="password" name="password.again" id="password.again" value="" class="span2 error" placeholder="Register.PasswordAgain" />
    <span class="help-inline">The password confirmation does not match the password</span></div>
</div>
</form>';

is_html( $rendered, $expected, 'got expected html' );

done_testing;
