use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_messages {
        {
            required => 'You must supply this field',
        }
    }
    has_field 'foo' => ( type => 'Text', required => 1 );
    has_field 'bar';
}

my $form = Test::Form->new;
ok( $form, 'form built');
$form->process( params => { bar => 1} );
my @errors = $form->errors;
is( $errors[0], 'You must supply this field', 'form has errors' );

done_testing;
