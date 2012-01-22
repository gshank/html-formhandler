use strict;
use warnings;
use Test::More;

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
like( $rendered, qr{<label class="label" title="Bar Field" for="bar">}, 'label_attr on label' );
like( $rendered, qr{<div class="minx finx">}, 'classes on div for field' );

{
    package MyApp::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar';
    has_field 'mox';

    sub field_html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        # $type is one of input, label, wrapper
        $attr = {
            class => [$type, 'hfh']
        };
        return $attr;
    }
}

$form = MyApp::Form->new;
$form->process( params => {} );
$rendered = $form->render;

done_testing;
