use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test-form' );
    has_field 'foo';
    has_field 'bar';

}

my $form = MyApp::Form::Test->new;
ok( $form );

$form->process( params => {} );

my $rendered = $form->field('foo')->render_elementx( element_class => ['ex111', 'cg33'] );

my $expected = '
<input class="ex111 cg33" id="foo" name="foo" type="text" value="" />
';

$rendered = $form->field('bar')->renderx( element_class => ['ex113', 'cg34'] );
$expected = '
<div>
  <label for="bar">Bar</label>
  <input class="ex113 cg34" id="bar" name="bar" type="text" value="" />
</div>
';

is_html( $rendered, $expected );

$rendered = $form->renderx( form_element_class => ['ggg', 'www'] );
$expected = '
<form class="ggg www" id="test-form" method="post">
<div class="form_messages"></div>
<div>
  <label for="foo">Foo</label>
  <input class="ex111 cg33" id="foo" name="foo" type="text" value="" />
</div>
  <div><label for="bar">Bar</label>
  <input class="ex113 cg34" id="bar" name="bar" type="text" value="" />
</div>
</form>
';
is_html( $rendered, $expected );

done_testing;

