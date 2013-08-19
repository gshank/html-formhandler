use strict;
use warnings;
use Test::More;
use Test::Exception;

{
    package Test::Form::User;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Widget::Theme::Bootstrap';

    has '+item_class' => ( default => 'User' );

    sub build_render_list { ['details', 'protect','submit'] }

    has_field 'first_name' => (
        type             => 'Text',
        required         => 1,
        required_message => 'Please enter your first name.',
        label            => 'First name',
        wrapper_class    => ['span5'],
    );

    has_field 'last_name' => (
        type             => 'Text',
        required         => 1,
        required_message => 'Please enter your last name.',
        label            => 'First name',
        wrapper_class    => ['span5'],
   );
    has_field 'new_password' => (
        type      => 'Password',
        label     => 'New Password',
        required  => 1,
        minlength => 5,
        wrapper_class    => ['span5'],
    );

    has_field 'new_password_conf' => (
       type           => 'PasswordConf',
       label          => 'New Password (again)',
       password_field => 'new_password',
       required       => 1,
       minlength      => 5,
       wrapper_class     => ['span10'],
    );

    has_field 'submit'  => ( type => 'Submit', value => 'Proceed', element_class => ['btn btn-yellow'] );

    has_block 'details' => ( tag => 'fieldset',
                                        render_list => ['first_name','last_name'],
                                        label => 'Register a new account' );
    has_block 'protect' => ( tag => 'fieldset',
                                         label => 'Protect your information with a password',
                                         render_list => ['new_password', 'new_password_conf'] );

}

my $form = Test::Form::User->new;
ok( $form );

my $result = $form->run( params => {} );
lives_ok( sub { $result->render; }, 'renders ok' );

done_testing;
