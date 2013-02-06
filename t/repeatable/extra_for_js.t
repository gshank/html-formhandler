use strict;
use warnings;
use Test::More;

{
    package Test::User::Repeatable;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'user_name';
    has_field 'occupation';
    has_field 'employers' => ( type => 'Repeatable', extra_for_js => 'XXX' );
    has_field 'employers.employer_id' => ( type => 'PrimaryKey' );
    has_field 'employers.name';
    has_field 'employers.address';
}
my $form = Test::User::Repeatable->new;
ok( $form->field('employers')->field('XXX'), 'extra field from field results');

my $unemployed_params = {
   user_name => "No Employer",
   occupation => "Unemployed",
   'employers.0.employer_id' => '', # empty string
   'employers.0.name' => '',
   'employers.0.address' => ''
};
$form->process( $unemployed_params);

ok( $form->field('employers')->field('XXX'), 'extra field from input results' );

done_testing;
