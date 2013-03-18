use strict;
use warnings;
use Test::More;

# this tests to make sure that a display field can take a value
{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( type => 'Display',  label => undef,  required => 0,  noupdate => 1 );
    has_field 'bar' => ( type => 'Text' );

}

my $form = MyApp::Form::Test->new;
ok( $form );

my $init_obj = {
    foo => 'some foo',
    bar => 'a bar',
};

$form->process( init_object => $init_obj, params => {} );
is( $form->field('foo')->value, 'some foo', 'foo field has a value' );

my $rendered = $form->render;

done_testing;
