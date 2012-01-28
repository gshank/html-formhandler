use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_html_attr { { method => 'GET', class => 'hfh test_form', target => '_blank' } }
#   sub build_wrapper_attr { { class => 'form_wrapper' } }
    has_field 'foo' => ( html_attr => { arbitrary => 'something' } );
    has_field 'bar' => ( html_attr => { writeonly => 1 }, label_attr => { title => 'Bar Field' } );
    has_field 'mox' => ( wrapper_attr => { class => ['minx', 'finx'] } );
    has_field 'my_text' => ( type => 'TextArea', html_attr => { required => "required" } );
}

my $form = Test::Form->new;
$form->process( params => {} );
my $rendered = $form->render;
like( $rendered, qr/class="hfh test_form"/, 'form has class' );
like( $rendered, qr/method="GET"/, 'form has html method' );
like( $rendered, qr/arbitrary="something"/, 'field has arbitrary attribute' );
like( $rendered, qr/writeonly="1"/, 'field has writeonly attribute' );
like( $rendered, qr/target="_blank"/, 'form has target attribute');
like( $rendered, qr{<textarea name="my_text" id="my_text" required="required" rows="5" cols="10"></textarea>}, 'textarea rendered ok');
like( $rendered, qr{<label title="Bar Field" for="bar">}, 'label_attr on label' );
like( $rendered, qr{<div class="minx finx">}, 'classes on div for field' );

{
    package MyApp::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_widget_tags { { form_wrapper => 1 } }
    has '+name' => ( default => 'myapp_form' );
    sub build_html_attr { { name => 'myapp_form' } }
    sub build_wrapper_attr { { class => 'form_wrapper' } }
    has_field 'foo';
    has_field 'bar';
    has_field 'mox' => ( html_attr => { placeholder => 'my placeholder' } );;

    sub field_html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        # $type is one of input, label, wrapper
        my $class = $attr->{class} || '';
        $attr->{class} = [$type, 'hfh'];
        push @{$attr->{class}}, 'error' if $class =~ /error/;
        if( exists $attr->{placeholder} ) {
            $attr->{placeholder} = $self->_localize($attr->{placeholder});
        }
        return $attr;
    }
}

$form = MyApp::Form->new;
$form->process( params => {} );
my $expected =
'<fieldset class="form_wrapper">
<form id="myapp_form" method="post" name="myapp_form" >
<div class="wrapper hfh"><label class="label hfh" for="foo">Foo</label><input type="text" name="foo" id="foo" value="" class="input hfh" /></div>
<div class="wrapper hfh"><label class="label hfh" for="bar">Bar</label><input type="text" name="bar" id="bar" value="" class="input hfh" /></div>
<div class="wrapper hfh"><label class="label hfh" for="mox">Mox</label><input type="text" name="mox" id="mox" value="" class="input hfh" placeholder="my placeholder" /></div>
</form></fieldset>';
$rendered = $form->render;

is_html($rendered, $expected, 'renders correctly');

done_testing;
