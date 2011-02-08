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
