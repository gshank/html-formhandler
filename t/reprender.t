#[10:37] < wahoomike> hey everyone, a question about repeatable fields if i may
#[10:37] < wahoomike> i have a form with a repeatable field and a 'contains' sub-field definition
#[10:38] < wahoomike> as well as a non-zero num_when_empty attribute
#[10:38] < wahoomike> before processing, on the first request (via catalyst), the form renders correctly with N empty fields for the repeatable field
#[10:39] < wahoomike> after processing a POST with no values for that repeatable field, the form doesn't render any instances of the sub-field
#[10:40] < wahoomike> not sure how things work internally, but it looks like, during processing, sub-field instances are only created when there is a 
#                     POST value given for at some index in the repeatable field
#[10:42] < wahoomike> so when validation for some other field fails, and i try to render the processed form, i lose the sub-field input entirely
#[10:42] < wahoomike> is there a way to work around this?  am i doing something wrong?

use strict;
use warnings;
use Test::More;

{
    package Test::Repeatable::Array;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'my_array' => ( type => 'Repeatable', num_when_empty => 2 );
    has_field 'my_array.contains' => ( type => 'Text' );
    has_field 'my_rep' => ( type => 'Repeatable', 'num_when_empty' => 2 );
    has_field 'my_rep.foo';
    has_field 'bar';

}

my $form = Test::Repeatable::Array->new;
my $rendered_array = $form->field('my_array')->render;
like( $rendered_array, qr/my_array\.0/, 'renders my_array field' );
my $rendered_rep = $form->field('my_rep')->render;
like( $rendered_rep, qr/my_rep\.0/, 'renders my_rep field' );
$form->process( params => {} );
$rendered_array = $form->field('my_array')->render;
like( $rendered_array, qr/my_array\.0/, 'renders my_array field' );
$rendered_rep = $form->field('my_rep')->render;
like( $rendered_rep, qr/my_rep\.0/, 'renders my_rep field' );

$form->process( params => { foo => 'xxx', bar => 'yyy', 
   'my_array.0' => '', 'my_array.1' => '',
   'my_rep.0.foo' => '', 'my_rep.1.foo' => '' } );
$rendered_array = $form->field('my_array')->render;
like( $rendered_array, qr/my_array\.0/, 'renders my_array field' );
$rendered_rep = $form->field('my_rep')->render;
like( $rendered_rep, qr/my_rep\.0/, 'renders my_rep field' );

done_testing;
