use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_widget_tags {
        {
            form_wrapper_attr => {},
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
like( $rendered, qr/<span class="label" for="bar">Bar<\/span>/, 'label formatted with span and class' );
ok( ! exists $form->field('foo')->widget_tags->{form_wrapper_attr}, 'no form widgets tags in fields' );

{
    package MyApp::Form::Theme::Basic;
    use Moose::Role;
    sub build_widget_tags {
        {
            form_wrapper => 1,
            form_wrapper_tag => 'div',
            label_tag => 'span',
            type => {
                'Compound' => { wrapper => 1, wrapper_tag => 'span' },
            }
        }
    }
    sub field_html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        $attr->{class} = ['frm', 'ele'] if $type eq 'input';
        $attr->{class} = ['frm', 'lbl'] if $type eq 'label';
        $attr->{class} = ['frm', 'wrp'] if $type eq 'wrapper';
        return $attr;
    }
}
{
    package MyApp::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'MyApp::Form::Theme::Basic';

    has_field 'my_comp' => ( type => 'Compound' );
    has_field 'my_text' => ( type => 'Text' );
}

done_testing;
