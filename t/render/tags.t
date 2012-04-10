use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_form_tags {{
        form_text => 'testing',
    }}
    sub build_update_subfields {{
        all => { tags => { wrapper_tag => 'p', label_tag => 'span', } },
    }}
    has_field 'foo';
    has_field 'bar';
    has_field 'vax';
    has_field 'multi' => ( type => 'Compound' );
    has_field 'multi.one';
    has_field 'multi.two';
    has_field 'records' => ( type => 'Repeatable' );
    has_field 'records.one';
    has_field 'records.two';
    sub html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        $attr->{class} = ['label'] if $type eq 'label';
        return $attr;
    }
}

my $form = Test::Form->new;
$form->process({});
my $rendered = $form->render;
unlike( $rendered, qr/fieldset/, 'no fieldset rendered' );
unlike( $rendered, qr/Foo: /, 'no colon in label' );
like( $rendered, qr/<p/, 'wrapper tag correct' );
unlike( $rendered, qr/<fieldset class="multi"><legend>Multi<\/legend>/, 'no fieldset around compound' );
like( $rendered, qr/<span class="label">Bar<\/span>/, 'label formatted with span and class' );

ok( ! exists $form->field('foo')->tags->{form_text}, 'no form widgets tags in fields' );
my $exp_tags = { wrapper_tag => 'p', label_tag => 'span' };
my $got_tags = $form->field('records.0')->tags;
is_deeply( $got_tags, $exp_tags, 'correct tags' );


{

    package Test::Tags;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    sub build_do_form_wrapper {1}
    sub build_update_subfields {{ all => { tags => { wrapper_tag => 'p' } } }}
    has_field 'bar' => ( tags =>
         {wrapper_tag => 'span'});
    has_field 'baz' => ( do_wrapper => 0 );

    sub html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        $attr->{class} = 'label' if $type eq 'label';
        return $attr;
    }
}

$form = Test::Tags->new;
$form->process( { foo => 'bar' } );
is_html( $form->field('foo')->render, '
<p><label class="label" for="foo">Foo</label><input type="text" name="foo" id="foo" value="bar" />
</p>', 'renders with different tags');

is_html( $form->field('bar')->render, '
<span><label class="label" for="bar">Bar</label><input type="text" name="bar" id="bar" value="" />
</span>', 'field renders with custom tags' );

is_html( $form->field('baz')->render, '
<label class="label" for="baz">Baz</label><input type="text" name="baz" id="baz" value="" />',
'field renders with false wrapper_tag' );

done_testing;
