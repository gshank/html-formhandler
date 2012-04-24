use strict;
use warnings;
use Test::More;
use Data::Dumper;

# tests that an init_value provided by item/init_object is used
# for disabled fields
{
    {
        package MyApp::Test::Form1;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( type => 'Select', disabled => 1 );
        has_field 'bar';
        has_field 'save' => ( type => 'Submit' );
    }

    my $form = MyApp::Test::Form1->new;
    my $init_object = { foo => 'my_foo', bar => 'my_bar' };
    $form->process( init_object => $init_object, params => {} );
    is_deeply( $form->fif, $init_object, 'fif is correct' );
    my $submitted = { bar => 'subm_bar' };
    $form->process( init_object => $init_object, params => $submitted );
    is_deeply( $form->fif, { foo => 'my_foo', bar => 'subm_bar' },
       'right fif after submission, init_object' );
    is_deeply( $form->value, { foo => 'my_foo', bar => 'subm_bar' } );
}

{
    {
        package MyApp::Test::Form2;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( type => 'Select', disabled => 1, default => 'def_foo' );
        has_field 'bar' => ( default => 'def_bar' );
        has_field 'save' => ( type => 'Submit' );
    }

    my $form = MyApp::Test::Form2->new;
    $form->process( params => {} );
    my $fif = { foo => 'def_foo', bar => 'def_bar' };
    is_deeply( $form->fif, $fif, 'fif is correct using defaults' );
    my $submitted = { bar => 'subm_bar' };
    $form->process( params => $submitted );
    is_deeply( $form->fif, { foo => 'def_foo', bar => 'subm_bar' },
       'right fif after submission' );
    is_deeply( $form->value, { foo => 'def_foo', bar => 'subm_bar' } );
}

done_testing;
