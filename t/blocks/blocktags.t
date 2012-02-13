use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::BlockComment;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test_form' );
    has_block 'comment' => ( tag => 'a', content => 'This is a comment from a block',
        class => ['comment' ] );
    has_field 'foo' => ( tags => { before_element => '%comment' } );
    has_field 'bar' => ( tags => { before_element => \&bar_element } );

    sub bar_element {
        my $self = shift;
        return '<div>In a Sub</div>';
    }
}

my $form = MyApp::Form::BlockComment->new;
ok( $form, 'form built' );
$form->process;
my $rendered = $form->render;
my $expected =
'<form id="test_form" method="post">
  <div class="form_messages"></div>
  <div>
    <label for="foo">Foo</label>
    <a class="comment">This is a comment from a block</a>
    <input id="foo" name="foo" type="text" value="" />
  </div>
  <div>
    <label for="bar">Bar</label>
    <div>In a Sub</div>
    <input id="bar" name="bar" type="text" value="" />
  </div>
</form>';

is_html( $rendered, $expected, 'rendered as expected' );

done_testing;
