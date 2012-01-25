use strict;
use warnings;
use Test::More;


my $struct = {
   username => 'Joe Blow',
   occupation => 'Programmer',
   tags => ['Perl', 'programming', 'Moose' ],
   employer => {
      name => 'TechTronix',
      country => 'Utopia',
   },
};


{
   package Structured::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'username';
   has_field 'occupation';
   has_field 'tags' => ( type => 'Repeatable' );
   has_field 'tags.contains' => ( type => 'Text' );
   has_field 'employer' => ( type => 'Compound' );
   has_field 'employer.name';
   has_field 'employer.country';

}

my $form = Structured::Form->new;
ok( $form, 'form created' );
$form->process( params => $struct );
ok( $form->validated, 'form validated');

is_deeply( $form->field('tags')->value, ['Perl', 'programming', 'Moose' ],
   'list field tags has right values' );
my $result = $form->result;
is( $result->num_results, 4, 'right number of results');

my $first_tag = $result->field('tags.0');
is( ref $first_tag, 'HTML::FormHandler::Field::Result', 'get result object');
is( $first_tag->value, 'Perl', 'result has right value' );
is( $first_tag->parent, $result->field('tags'), 'correct parent for ');

my $employer = $result->field('employer');
my $employer_name = $result->field('employer.name');
is( $employer_name->parent, $employer, 'correct parent for compound field');

my $fif = {
   'employer.country' => 'Utopia',
   'employer.name' => 'TechTronix',
   'occupation' => 'Programmer',
   'tags.0' => 'Perl',
   'tags.1' => 'programming',
   'tags.2' => 'Moose',
   'username' => 'Joe Blow'
};

is_deeply( $form->fif, $fif, 'fif is correct' );

$result = $form->run( $fif );

ok( $result->validated, 'form processed from fif' );

is_deeply( $result->value, $struct, 'values round-tripped from fif');

done_testing;
