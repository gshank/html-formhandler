use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+is_html5' => ( default => 1 );

    has_field 'foo' => ( type => 'Hidden', required => 1 );
    has_field 'bar' => ( type => 'Text', required => 1 );;

}

my $form = MyApp::Form::Test->new;
ok( $form );

my $rendered = $form->field('foo')->render;
my $expected = q{
<div><input id="foo" name="foo" type="hidden" value="" /></div>
};
is_html($rendered, $expected, 'no required on hidden field');

$rendered = $form->field('bar')->render;
$expected = q{
<div><label for="bar">Bar</label><input id="bar" name="bar" required="required" type="text" value="" /></div>
};
is_html($rendered, $expected, 'required on text field');

done_testing;
