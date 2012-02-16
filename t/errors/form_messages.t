use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'testform' );
    has '+success_message' => ( default => 'Successfully Submitted' );
    has_field 'foo';
    has_field 'bar';

}

my $form = MyApp::Test::Form->new;

my $params = {
    foo => 'myfoo',
    bar => 'mybar',
};
$form->process( params => $params );
ok( $form->validated, 'form validated' );
my $rendered = $form->render;
my $expected =
'<form id="testform" method="post">
  <div class="form_messages">
    <span class="success_message">Successfully Submitted</span>
  </div>
  <div>
    <label for="foo">Foo</label>
    <input type="text" id="foo" name="foo" value="myfoo" />
  </div>
  <div>
    <label for="bar">Bar</label>
    <input type="text" id="bar" name="bar" value="mybar" />
  </div>
</form>';
is_html( $rendered, $expected, 'success message rendered ok' );

$form->process( params => {} );
$rendered = $form->render;
unlike( $rendered, qr/class="success_message"/, 'no success message when not validated' );

done_testing;
