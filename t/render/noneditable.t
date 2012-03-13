use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Widget::Theme::Bootstrap';

    has '+name' => ( default => 'testform' );
    has_field 'foo';
    has_field 'non_edit' => ( type => 'NonEditable', value => 'This is a Test' );
    has_field 'bar';

}

my $form = MyApp::Form::Test->new;
$form->process( params => { foo => 'my_foo', bar => 'my_bar' } );

my $rendered = $form->render;
my $expected =
'<form class="form-horizontal" id="testform" method="post">
    <div class="alert alert-success">
    <span>Your form was successfully submitted</span>
    </div>
    <div class="control-group">
        <label class="control-label" for="foo">Foo</label>
        <div class="controls">
        <input type="text" name="foo" id="foo" value="my_foo" /></div>
    </div>
    <div class="control-group">
        <label class="control-label" for="non_edit">Non edit</label>
        <div class="controls">
        <span id="non_edit" />This is a Test</span></div>
    </div>
    <div class="control-group">
        <label class="control-label" for="bar">Bar</label>
        <div class="controls">
        <input type="text" name="bar" id="bar" value="my_bar" /></div>
    </div>
</form>';
is_html( $rendered, $expected, 'form with uneditable field renders ok' );

done_testing;
