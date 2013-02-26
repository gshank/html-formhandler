use strict;
use warnings;
use Test::More;
use Data::Dumper;

# tests that an init_value provided by item/init_object is used
# for disabled fields, and that disabled fields are not validated.
{
    {
        package MyApp::Test::Form1;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( type => 'Select', disabled => 1 );
        has_field 'bar';
        has_field 'user' => ( type => 'Compound', required => 1 );
        has_field 'user.email_address' => ( disabled => 1, required => 1,
            validate_method => \&check_email
        );
        sub check_email {
            my $self = shift;
            if ( $self->value && $self->value =~ /joe/ ) {
                $self->add_error("No emails with 'joe'");
            }
        }
        has_field 'save' => ( type => 'Submit' );
    }

    my $form = MyApp::Test::Form1->new;
    my $init_object = {
        foo => 'my_foo',
        bar => 'my_bar',
        user => { email_address => 'joe@nowhere.com' },
    };
    $form->process( init_object => $init_object, params => {} );
    my $fif = {
        foo => 'my_foo',
        bar => 'my_bar',
        'user.email_address' => 'joe@nowhere.com',
    };
    is_deeply( $form->fif, $fif, 'fif is correct' );
    my $submitted = {
        bar => 'subm_bar',
    };

    $form->process( init_object => $init_object, params => $submitted );
    $fif->{bar} = 'subm_bar';
    is_deeply( $form->fif, $fif,
       'right fif after submission, init_object' );
    $init_object->{bar} = 'subm_bar';
    is_deeply( $form->value, $init_object, 'right value' );
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
