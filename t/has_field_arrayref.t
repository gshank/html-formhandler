package Test::HTML::FormHandler::HasFieldArrayRef;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has_field [qw/home work mobile/] => (type=>'Text', required=>1);

no HTML::FormHandler::Moose;

use Test::More;

ok my $form1 = Test::HTML::FormHandler::HasFieldArrayRef->new,
  'Created Form';

ok my %params1 = (
    home => '1112223333',
    work => '4445556666',
    mobile => '7778889999',
), 'Created Params Hash';

ok my $result1 = $form1->process(params=>\%params1),
  'got good result';

ok !$form1->has_errors,
  'No errors';

ok my $form2 = Test::HTML::FormHandler::HasFieldArrayRef->new,
  'Created Form';

ok my %params2 = (
    home => '1112223333',
    work => '4445556666',
), 'Created Params Hash';

ok ! (my $result2 = $form2->process(params=>\%params2)),
  'got correct failing result';

ok $form2->has_errors,
  'Yes there are errors';

done_testing;
