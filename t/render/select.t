use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test_form' );
    has_field 'fruit'      => ( type => 'Select' );
    has_field 'vegetables' => ( type => 'Multiple' );
    sub options_fruit {
        return (
            '"apples"' => '"apples"',
            '<oranges>' => '<oranges>',
            '&kiwi&' => '&kiwi&',
        );
    }

    sub options_vegetables {
        return (
            '<lettuce>' => '<lettuce>',
            'broccoli' => 'broccoli',
            'carrots' => 'carrots',
            '& peas' => '& peas',
        );
    }
}

my $form = Test::Form->new;
my $params = {
    fruit              => '<oranges>',
    vegetables         => [ 'broccoli', '& peas' ],
};
$form->process( $params );

my $rendered = $form->field('fruit')->render;
my $expected =
'<div>
  <label for="fruit">Fruit</label>
  <select name="fruit" id="fruit">
    <option value="&quot;apples&quot;" id="fruit.0">&quot;apples&quot;</option>
    <option value="&lt;oranges&gt;" id="fruit.1" selected="selected">&lt;oranges&gt;</option>
    <option value="&amp;kiwi&amp;" id="fruit.2">&amp;kiwi&amp;</option>
  </select>
</div>';
is_html( $rendered, $expected, 'output from select field');

$rendered = $form->field('vegetables')->render;
$expected =
'<div>
  <label for="vegetables">Vegetables</label>
  <select name="vegetables" id="vegetables" multiple="multiple" size="5">
    <option value="&lt;lettuce&gt;" id="vegetables.0">&lt;lettuce&gt;</option>
    <option value="broccoli" id="vegetables.1" selected="selected">broccoli</option>
    <option value="carrots" id="vegetables.2">carrots</option>
    <option value="&amp; peas" id="vegetables.3" selected="selected">&amp; peas</option>
  </select>
</div>';
is_html( $rendered, $expected, 'output from select multiple field');

done_testing;
