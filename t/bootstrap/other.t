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
    has_field 'bar' => (
      tags => { before_element => '<p>Start</p>',
                after_element => '<p>End</p>',
      }
    );

}

my $form = MyApp::Form::Test->new;
ok( $form );

my $rendered = $form->field('foo')->render;
my $expected = '<div><input id="foo" name="foo" type="hidden" value="" /></div>';
is_html( $rendered, $expected, 'rendered ok' );

$rendered = $form->field('bar')->render;
$expected = '
<div class="control-group">
  <label class="control-label" for="bar">Bar</label>
  <div class="controls">
  <p>Start</p>
  <input id="bar" name="bar" type="text" value="" />
  <p>End</p>
   </div>
</div>';
is_html( $rendered, $expected, 'tags rendered ok' );

done_testing;
