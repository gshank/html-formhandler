use strict;
use warnings;
use Test::More;

use HTML::FormHandler::Field::Text;

my $field = HTML::FormHandler::Field::Text->new( name => 'test' );

my $string = '"J.Doe" <jdoe@gmail.com>';

my $output = $field->html_filter($string);
is( $output, '&quot;J.Doe&quot; &lt;jdoe@gmail.com&gt;', 'output ok' );

{
    package Test::RenderFilter;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar';

    sub render_filter {
        my ( $self, $string ) = @_;
        $string =~ s/my/MY/g;
        return $string;
    }
}

my $form = Test::RenderFilter->new;
ok( $form, 'form builds' );

$form->process( params => { foo => 'This is my test' } );
like( $form->field('foo')->render, qr/MY/, 'rendering was filters' );

{
    package Test::FieldFilter;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( render_filter => \&foo_render );
    has_field 'bar' => ( render_filter => sub { shift } );
    sub foo_render {
        my $string = shift;
        $string =~ s/yours/YOURS/g;
        return $string;
    }
}

$form = Test::FieldFilter->new;
$form->process( params => { foo => "What's mine is yours", bar => '<what a hoot>' } );  
is( $form->field('bar')->render, '
<div><label class="label" for="bar">Bar: </label><input type="text" name="bar" id="bar" value="<what a hoot>" /></div>
', 'renders ok' );
is( $form->field('foo')->render, '
<div><label class="label" for="foo">Foo: </label><input type="text" name="foo" id="foo" value="What\'s mine is YOURS" /></div>
', 'renders ok' );

done_testing;
