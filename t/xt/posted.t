use strict;
use warnings;
use Test::More;

use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = HTML::FormHandler::I18N->get_handle('en_en');

{
    package Test::SingleBool;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'opt_in' => ( type => 'Boolean', required => 1 );
}

{
    my $form = Test::SingleBool->new;
    ok( $form, 'form built' );
    $form->process( params => {} );
    ok( !$form->ran_validation, 'form did not run validation' );

    my $test = 'POST';
    $form->process( posted => ($test eq 'POST'), params => {} );
    ok( $form->ran_validation, 'form did run validation' );
    ok( $form->has_errors, 'form has errors' );

    my @errors = $form->errors;
    is( scalar @errors, 1, 'form has an error' );
    is( $errors[0], 'Opt in field is required', 'error message is correct' );
}

{
    package Test::SingleBoolCompound;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';


    has_field 'a' => ( type => 'Compound', required => 1 );
    has_field 'a.opt_in' => ( type => 'Boolean', required => 1 );
}

{
    my $form = Test::SingleBoolCompound->new;
    ok( $form, 'form built' );
    $form->process( params => {} );
    ok( !$form->ran_validation, 'form did not run validation' );

    my $test = 'POST';
    $form->process( posted => ($test eq 'POST'), params => {} );
    ok( $form->ran_validation, 'form did run validation' );
    ok( $form->has_errors, 'form has errors' );

    my @errors = $form->errors;
    is( scalar @errors, 1, 'form has an error' );
    is( $errors[0], 'A field is required', 'error message is correct' );
}

done_testing;

