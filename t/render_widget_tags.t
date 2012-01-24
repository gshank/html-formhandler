use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_tags' => ( default => sub {{
        no_auto_fieldset => 1,
        label_no_colon => 1,
        wrapper_tag => 'p',
        no_compound_wrapper => 1,
    }} );
    has_field 'foo';
    has_field 'bar';
    has_field 'vax';
    has_field 'multi' => ( type => 'Compound' );
    has_field 'multi.one';
    has_field 'multi.two';
}

my $form = Test::Form->new;
$form->process({});
my $rendered = $form->render;
unlike( $rendered, qr/fieldset/, 'no fieldset rendered' );
unlike( $rendered, qr/Foo: /, 'no colon in label' );
like( $rendered, qr/<p/, 'wrapper tag correct' );
unlike( $rendered, qr/<fieldset class="multi"><legend>Multi<\/legend>/, 'no fieldset around compound' );

done_testing;
