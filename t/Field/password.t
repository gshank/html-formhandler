use strict;
use warnings;

use Test::More;
my $tests = 11;
plan tests => $tests;

my $class = 'HTML::FormHandler::Field::Password';

my $name = $1 if $class =~ /::([^:]+)$/;

use_ok( $class );


# TODO why not just grab $field = $form->field('password') ?

my $form = my_form->new;

my $field = $class->new(
    name    => 'test_field',
    type    => $name,
    form    => $form, 
);



ok( defined $field,  'new() called' );

$field->input( '2192ab201def' );
$field->process;
ok( !$field->has_errors, 'Test for errors 1' );

$field->input( 'f oo' );
$field->process;
ok( $field->has_errors, 'has spaces' );

$field->input( 'abc%^%' );
$field->process;
ok( $field->has_errors, 'match \W' );

$field->input( '123456' );
$field->process;
ok( $field->has_errors, 'all digits' );

$field->input( 'ab1' );
$field->process;
ok( $field->has_errors, 'too short' );

$field->input( 'my4login55' );
$field->process;
ok( $field->has_errors, 'matches login' );

$field->input( 'my4username' );
$field->process;
ok( $field->has_errors, 'matches username' );

my $pass = 'my4user5name';
$field->input( $pass );
$field->process;
ok( !$field->has_errors, 'just right' );
is ( $field->value, $pass, 'Input and value match' );


package my_form;
use strict;
use warnings;
use base 'HTML::FormHandler';

sub field_list {
    return {
        optional => {
            login       => 'Text',
            username    => 'Text',
            password    => 'Password',
        },
    };
}


sub params {
    {
        login       => 'my4login55',
        username    => 'my4username',
    };
}

