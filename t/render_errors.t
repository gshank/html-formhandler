use strict;
use warnings;
use Test::More;
use HTML::TreeBuilder;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test_errors' );
    has_field 'foo' => ( required => 1 );
    has_field 'bar' => ( type => 'Integer' );

}

my $form = Test::Form->new;
$form->process( params => { bar => 'abc' } );

is( $form->num_errors, 2, 'got two errors' );

my $expected = '<form id="test_errors" method="post" >
<fieldset class="main_fieldset">
<div class="error"><label class="label" for="foo">Foo: </label><input type="text" name="foo" id="foo" value="" />
<span class="error_message">Foo field is required</span></div>
<div class="error"><label class="label" for="bar">Bar: </label><input type="text" name="bar" id="bar" size="8" value="abc" />
<span class="error_message">Value must be an integer</span></div>
</fieldset></form>';
my $rendered = $form->render;

my $exp_tree = HTML::TreeBuilder->new_from_content($expected);
my $got_tree = HTML::TreeBuilder->new_from_content($rendered);
is($exp_tree->as_HTML, $got_tree->as_HTML, 'error rendering matches expected');

done_testing;
