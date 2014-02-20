use strict;
use warnings;
use Test::More;

{
    package MyApp::Form::Rep;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'testform' );
    has_field 'test';
    has_field 'my_array' => ( type => 'Repeatable', required => 1, inactive => 1 );
    has_field 'my_array.one';
    has_field 'my_array.two';
}

my $form = MyApp::Form::Rep->new;
ok( $form );
my $params = {
   'text' => 'foo',
};
$form->process( params => $params );
ok( !$form->has_errors, 'form has no errors' );

done_testing;
