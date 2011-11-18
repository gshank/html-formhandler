use strict;
use warnings;
use Test::More;
use Test::Exception;

use lib 't/lib';
{
    package Test::ExtForm;
    use Moose;
    extends 'HTML::FormHandler';
    use HTML::FormHandler::Moose;

    has_field 'foo';
    has_field 'bar';

}
{
    package Test::SubExtForm;
    use Moose;
    extends 'Test::ExtForm';
    use HTML::FormHandler::Moose;

    has_field 'fubar';
}

dies_ok( sub { require Form::NoExtForm; }, 'dies when not extending' );

my $form = Test::ExtForm->new;
ok($form, 'got a HFH object');
$form = Test::NoExtForm->new;
ok($form, 'got a no-HFH object');
$form = Test::SubExtForm->new;
ok($form, 'got an subclassed form');
$form = Test::SubExtForm->new;
ok($form, 'got a second subclassed form');

done_testing;
