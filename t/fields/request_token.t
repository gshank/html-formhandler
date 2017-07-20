use strict;
use warnings;
use Test::More;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Field::Role::RequestToken';

    has_field 'foo';
    has_field 'bar';

    has_field '_token' => ( type => 'RequestToken' );

    has_field 'save' => ( type => 'Submit' );

}

my $form = MyApp::Form::Test->new;
ok( $form );

$form->process( params => { _token => 'wrong', foo => 'blahblah' } );
ok( ! $form->validated, 'form did not validate without form token' );

done_testing;
