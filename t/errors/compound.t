use strict;
use warnings;
use Test::More;

# shows behavior of required flag in compound fields
{
    package MyApp::Form::User;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'userform' );

    has_field 'name';
    has_field 'email';
    has_field 'address' => ( type => 'Compound' );
    has_field 'address.city' => ( required => 1 );
    has_field 'address.state' => ( required => 1 );

}

my $form = MyApp::Form::User->new;
my $params = {
    name => 'John Doe',
    email => 'jdoe@gmail.com',
};

# no errors if compound subfields are required but missing
# and compound field is not required
$form->process( params => $params );
ok( $form->validated, 'no errors in form' );

# error if one field is entered and not the other
# and compound field is not required
$form->process( params => { %$params, 'address.city' => 'New York' } );
ok( $form->has_errors, 'error with one field filled' );

# errors if compound subfields are required & compound is required
$form->process( update_field_list => { address => { required => 1 } },
    params => $params );
ok( $form->has_errors, 'errors in form' );

done_testing;
