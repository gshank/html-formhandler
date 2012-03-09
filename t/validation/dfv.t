use strict;
use warnings;
use Test::More;

use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = HTML::FormHandler::I18N->get_handle('en_en');

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    use Data::FormValidator::Constraints ('match_state');

    has_field 'my_state' => (
        apply => [ { check => \&match_state, message => 'Invalid State' } ] );
    has_field 'two';
    has_field 'three';
}

my $form = MyApp::Form::Test->new;
ok( $form );
my $params = { my_state => 'XX', two => 1, three => 2 };
$form->process( params => $params );
ok( ! $form->validated, 'form did not validate' );
my @errors = $form->errors;
is( $errors[0], 'Invalid State', 'correct error message' );
$params->{my_state} = 'NY';
ok( $form->process( params => $params ), 'correct State validated' );

done_testing;
