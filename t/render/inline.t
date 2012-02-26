use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Rendering;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'my_comp' => ( type => 'Compound', widget_wrapper => 'SimpleInline', wrapper => 1 );
    has_field 'my_comp.one';
    has_field 'my_comp.two';
    has_field 'my_alt' => ( type => 'Compound',  widget_wrapper => 'TableInline', wrapper => 1 );
    has_field 'my_alt.one' => ( widget_wrapper => 'TableInline' );
    has_field 'my_alt.two' => ( widget_wrapper => 'TableInline' );;

    sub html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        $attr->{class} = 'label' if $type eq 'label';
        return $attr;
    }
}

my $form = Test::Rendering->new;
my $expected = '
<div><label class="label" for="my_comp.one">One</label><input type="text" name="my_comp.one" id="my_comp.one" value="" />
</div>
<div><label class="label" for="my_comp.two">Two</label><input type="text" name="my_comp.two" id="my_comp.two" value="" />
</div>';
my $rendered = $form->field('my_comp')->render;
is_html( $rendered, $expected, 'compound field with inline wrapper' );

is_html( $form->field('my_alt')->widget_wrapper, 'TableInline', 'widget wrapper works' );
$expected = '
<tr><td><label class="label" for="my_alt.one">One</label></td><td><input type="text" name="my_alt.one" id="my_alt.one" value="" /></td></tr>

<tr><td><label class="label" for="my_alt.two">Two</label></td><td><input type="text" name="my_alt.two" id="my_alt.two" value="" /></td></tr>
';
$rendered = $form->field('my_alt')->render;
is_html( $rendered, $expected, 'compound field with table inline wrapper' );

done_testing;
