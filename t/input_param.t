package Test::HTML::FormHandler::InputParam;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has_field 'base_name' => (
    type => 'Text',
    required => 1,
    input_param=> 'input_name',
);

use Test::More;

ok my $form1 = Test::HTML::FormHandler::InputParam->new,
  'Created Form';

ok my %params1 = (
    input_name => 'This is a mapped input',
), 'Created Params Hash';

ok my $result1 = $form1->process(params=>\%params1),
  'got good result';

ok !$form1->has_errors,
  'No errors';

ok my $form2 = Test::HTML::FormHandler::InputParam->new,
  'Created Form';

ok my %params2 = (
    base_name => 'This is a mapped input',
), 'Created Params Hash';

ok ! (my $result2 = $form2->process(params=>\%params2)),
  'got correct failing result';

ok $form2->has_errors,
  'Yes there are errors';

done_testing;
