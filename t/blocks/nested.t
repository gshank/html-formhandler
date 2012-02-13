use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Nested::View;
    use HTML::FormHandler::Moose::Role;

    sub build_render_list { ['fset1'] }
    has_block 'fset1' => ( tag => 'fieldset', label => 'First Fieldset',
        render_list => ['foo', 'bar', 'pax', 'fset1.sub1', 'fset1.sub2'],
    );
    has_block 'fset1.sub1' => ( tag => 'div', label => 'More Stuff',
        class => ['sub1'],
        render_list => ['fee', 'fie', 'fo'],
    );
    has_block 'fset1.sub2' => ( tag => 'div', label => 'And Even More',
        class => ['sub2'],
        render_list => ['fum', 'man'],
    );

}
{
    package MyApp::Form::Nested;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'MyApp::Form::Nested::View';

    has '+name' => ( default => 'nested_form' );
    has_field 'foo';
    has_field 'bar';
    has_field 'pax';
    has_field 'fee';
    has_field 'fie';
    has_field 'fo';
    has_field 'fum';
    has_field 'man';

}

my $form = MyApp::Form::Nested->new;
ok( $form, 'form built' );
$form->process;
my $rendered = $form->render;
my $expected =
'<form id="nested_form" method="post">
  <div class="form_messages"></div>
  <fieldset><legend>First Fieldset</legend>
    <div>
      <label for="foo">Foo</label>
      <input type="text" id="foo" name="foo" value="">
    </div>
    <div>
      <label for="bar">Bar</label>
      <input type="text" id="bar" name="bar" value="">
    </div>
    <div>
      <label for="pax">Pax</label>
      <input type="text" id="pax" name="pax" value="">
    </div>
    <div class="sub1">
      <span>More Stuff</span>
      <div>
        <label for="fee">Fee</label>
        <input type="text" id="fee" name="fee" value="">
      </div>
      <div>
        <label for="fie">Fie</label>
        <input type="text" id="fie" name="fie" value="">
      </div>
      <div>
        <label for="fo">Fo</label>
        <input type="text" id="fo" name="fo" value="">
      </div>
    </div>
    <div class="sub2">
      <span>And Even More</span>
      <div>
        <label for="fum">Fum</label>
        <input type="text" id="fum" name="fum" value="">
      </div>
      <div>
        <label for="man">Man</label>
        <input type="text" id="man" name="man" value="">
      </div>
    </div>
  </fieldset>
</form>';
is_html( $rendered, $expected, 'got expected rendering' );

done_testing;
