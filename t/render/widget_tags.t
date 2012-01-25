use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_widget_tags {
        {
            wrapper_tag => 'p',
            label_tag => 'span',
        }
    }
    has_field 'foo';
    has_field 'bar';
    has_field 'vax';
    has_field 'multi' => ( type => 'Compound' );
    has_field 'multi.one';
    has_field 'multi.two';
    sub field_html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        $attr->{class} = ['label'] if $type eq 'label';
    }
}

my $form = Test::Form->new;
$form->process({});
my $rendered = $form->render;
unlike( $rendered, qr/fieldset/, 'no fieldset rendered' );
unlike( $rendered, qr/Foo: /, 'no colon in label' );
like( $rendered, qr/<p/, 'wrapper tag correct' );
unlike( $rendered, qr/<fieldset class="multi"><legend>Multi<\/legend>/, 'no fieldset around compound' );
like( $rendered, qr/<span class="label" for="bar">Bar<\/span>/, 'label formatted with span and class' );

done_testing;
