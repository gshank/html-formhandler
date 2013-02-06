use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_wrapper' => ( default => 'Bootstrap' );

    has_field 'foo' => ( type => 'Hidden' );
    has_field 'bar';

}

my $form = MyApp::Form::Test->new;
ok( $form );

my $expected = '<div><input id="foo" name="foo" type="hidden" value="" /></div>';
my $rendered = $form->field('foo')->render;
is_html( $rendered, $expected );

done_testing;
