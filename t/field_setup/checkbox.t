use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;
use Test::Exception;

{
    package MyApp::Form::Field::EmailOptin;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Checkbox';

    sub build_label { 'Send me expert college planning tips and advice.' }
    has '+default'    => (default => 1,);
    sub build_wrapper_class { ['email-optin'] }
}

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+field_name_space' => ( default => sub { ['MyApp::Form::Field'] } );

    has_field 'foo' => (
        type => 'EmailOptin',
        option_wrapper => 'nonexistent',
    );
    has_field 'bar' => (
    );
}

my $form = MyApp::Form::Test->new;
ok( $form, 'form built' );

dies_ok( sub { $form->render }, 'form dies with error about option_wrapper' );

done_testing;
