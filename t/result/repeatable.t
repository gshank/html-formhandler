use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'name';
    has_field 'foo';
    has_field 'bar' => ( type => 'Repeatable' );
    has_field 'bar.one';
    has_field 'bar.two';
    has_field 'bar.three';
}

my $form = Test::Form->new;

# check results from fields
$form->process( params => {} );
my $result = $form->result;
my $peek = $result->peek;
like( $peek, qr/bar.0.one/, 'has empty repeatable result');
ok( $result->field('bar')->has_results, 'we have nested results');

# compare against results from input
$form->process( params => { name => 'test123', foo => 'again', bar => [{ one => 1, two => 2, three => 3}] } );
$peek = $form->result->peek;

$result = $form->result;
like( $peek, qr/bar.0.one/, 'has empty repeatable result');
ok( $result->field('bar')->has_results, 'we have nested results');

done_testing;
