use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

# an example of how to setup a form for adding repeatable elements.
# not much to actually test here...
{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::RepeatableJs';

    has_field 'foo' => ( type => 'Repeatable', setup_for_js => 1);
    has_field 'foo.one';
    has_field 'foo.two';
    has_field 'add_element' => ( type => 'AddElement', repeatable => 'foo',
        value => 'Add another foo',
    );
    has_field 'bar';

}

my $form = MyApp::Form::Test->new;
ok( $form );

ok( $form->has_for_js, 'for_js data is built');

my $js = $form->render_repeatable_js;
ok( $js, 'got some javascript' );

my $expected = '<div><div class="add_element btn" data-rep-id="foo" id="add_element">Add another foo</div></div>';
my $rendered = $form->field('add_element')->render;
is_html( $rendered, $expected, 'add_element rendered ok' );


done_testing;
