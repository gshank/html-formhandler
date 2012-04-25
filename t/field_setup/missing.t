use strict;
use warnings;
use Test::More;

{

    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test_form' );

    has_field 'foo' => ( required => 1 );
    has_field 'bar' => ( required => 1 );;
}

my $form = MyApp::Form::Test->new;
$form->process( params => {} );
ok( ! $form->field('bar')->missing, 'bar is not missing' );
ok( ! $form->field('foo')->missing, 'foo is not missing' );
$form->process( params => { foo => 'my_foo', bar => '' } );
ok( $form->field('bar')->missing, 'bar is missing' );
ok( ! $form->field('foo')->missing, 'foo is not missing' );

done_testing;
