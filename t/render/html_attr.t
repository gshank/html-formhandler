use strict;
use warnings;
use Test::More;
use HTML::TreeBuilder;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+html_attr' => ( default => sub { { method => 'GET', class => 'hfh test_form', target => '_blank' } } );
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

    has '+name' => ( default => 'myapp_form' );
    has '+html_attr' => ( default => sub { { name => 'myapp_form' } } );
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
    }
}

$form = MyApp::Form->new;
$form->process( params => {} );
my $expected = '<form id="myapp_form" method="post" name="myapp_form" >
<fieldset class="main_fieldset">
<div class="wrapper hfh"><label class="label hfh" for="foo">Foo: </label><input type="text" name="foo" id="foo" value="" class="input hfh" /></div>
<div class="wrapper hfh"><label class="label hfh" for="bar">Bar: </label><input type="text" name="bar" id="bar" value="" class="input hfh" /></div>
<div class="wrapper hfh"><label class="label hfh" for="mox">Mox: </label><input type="text" name="mox" id="mox" value="" class="input hfh" placeholder="my placeholder" /></div>
</fieldset></form>';
$rendered = $form->render;

my $exp = HTML::TreeBuilder->new_from_content($expected);
my $got = HTML::TreeBuilder->new_from_content($rendered);
is( $exp->as_HTML, $got->as_HTML, "got expected rendering" );

done_testing;
