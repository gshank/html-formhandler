use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( required => 1, required_message => "You must supply a FOO!" );
    has_field 'bar' => ( required => 1, messages => { required => 'You must supply a BAR!' } );
    has_field 'baz';
}

my $form = Test::Form->new;

$form->process( params => {} );
$form->process( params => { baz => 'True' } );

my @errors = $form->errors;
is( scalar @errors, 2, 'right number of errors' );
is( $errors[0], 'You must supply a FOO!', 'right message for foo' );
is( $errors[1], 'You must supply a BAR!', 'right message for bar' );

done_testing;
