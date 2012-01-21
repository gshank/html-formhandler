use strict;
use warnings;
use Test::More;

{
    package Test::User::Repeatable;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'user_name';
    has_field 'occupation';
    has_field 'employers' => ( type => 'Repeatable', num_extra => 1 );
    has_field 'employers.employer_id' => ( type => 'PrimaryKey' );
    has_field 'employers.name';
    has_field 'employers.address';
}
my $form = Test::User::Repeatable->new;
my $unemployed_params = {
   user_name => "No Employer",
   occupation => "Unemployed",
   'employers.0.employer_id' => '', # empty string
   'employers.0.name' => '',
   'employers.0.address' => ''
};
$form->process( $unemployed_params);
ok( $form->validated, "User with empty employer validates" );
is_deeply( $form->value, { employers => [], user_name => 'No Employer', occupation => 'Unemployed' },
    'creates right value for empty repeatable' );
is_deeply( $form->fif, $unemployed_params, 'right fif for empty repeatable' );
$form->field('employers')->add_extra;
my $expected_fif = {
   'employers.0.address' => '',
   'employers.0.employer_id' => '',
   'employers.0.name' => '',
   'employers.1.address' => '',
   'employers.1.employer_id' => '',
   'employers.1.name' => '',
   'occupation' => 'Unemployed',
   'user_name' => 'No Employer',
};

is_deeply( $form->fif, $expected_fif, 'fif is correct with additional element' );

my $obj = {
    occupation => 'Flaneur',
    user_name  => 'billy',
    employers => [
        { name => 'First Employer', address => '', employer_id => 1 },
        { name => 'Second Employer', address => '', employer_id => 2 },
    ],
};

$form->process( init_object => $obj );
$expected_fif = {
   'occupation' => 'Flaneur',
   'user_name' => 'billy',
   'employers.0.address' => '',
   'employers.0.employer_id' => 1,
   'employers.0.name' => 'First Employer',
   'employers.1.address' => '',
   'employers.1.employer_id' => 2,
   'employers.1.name' => 'Second Employer',
   'employers.2.address' => '',
   'employers.2.employer_id' => '',
   'employers.2.name' => '',
};
is_deeply( $form->fif, $expected_fif, 'fif is correct with num_extra' );

done_testing;
