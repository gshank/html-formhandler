use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_form_element_attr { { method => 'GET', class => 'hfh test_form', target => '_blank' } }
    has_field 'foo' => ( element_attr => { arbitrary => 'something' } );
    has_field 'bar' => ( element_attr => { writeonly => 1 }, label_attr => { title => 'Bar Field' } );
    has_field 'mox' => ( wrapper_class => ['minx', 'finx'] );
    has_field 'my_text' => ( type => 'TextArea', element_attr => { required => "required" } );
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

    sub build_do_form_wrapper {1}
    sub build_form_wrapper_attr { { id => 'frm_wrapper' } }
    has '+name' => ( default => 'myapp_form' );
    sub form_element_attr { { name => 'myapp_form' } }
    has_field 'foo';
    has_field 'bar';
    has_field 'mox' => ( element_attr => { placeholder => 'my placeholder' } );;

    sub html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        # $type is one of element, label, wrapper
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
'<form id="myapp_form" class="form_element hfh"method="post" name="myapp_form" >
  <fieldset class="form_wrapper hfh" id="frm_wrapper">
  <div class="form_messages"></div>
  <div class="wrapper hfh"><label class="label hfh" for="foo">Foo</label><input type="text" name="foo" id="foo" value="" class="element hfh" /></div>
  <div class="wrapper hfh"><label class="label hfh" for="bar">Bar</label><input type="text" name="bar" id="bar" value="" class="element hfh" /></div>
  <div class="wrapper hfh"><label class="label hfh" for="mox">Mox</label><input type="text" name="mox" id="mox" value="" class="element hfh" placeholder="my placeholder" /></div>
</fieldset></form>';
$rendered = $form->render;

is_html($rendered, $expected, 'renders correctly');

done_testing;
