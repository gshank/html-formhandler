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
    has_field 'vegetables' => ( type => 'Multiple', empty_select => '-- Pick One --' );
    has_field 'my_option' => ( type => 'BoolSelect' );
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
    <option id="vegetables.0" value="">-- Pick One --</option>
    <option value="&lt;lettuce&gt;" id="vegetables.1">&lt;lettuce&gt;</option>
    <option value="broccoli" id="vegetables.2" selected="selected">broccoli</option>
    <option value="carrots" id="vegetables.3">carrots</option>
    <option value="&amp; peas" id="vegetables.4" selected="selected">&amp; peas</option>
  </select>
</div>';
is_html( $rendered, $expected, 'output from select multiple field');

$rendered = $form->field('my_option')->render;
$expected =
'<div>
  <label for="my_option">My option</label>
  <select name="my_option" id="my_option">
    <option value="" id="my_option.0">Select One</option>
    <option value="1" id="my_option.1">True</option>
    <option value="0" id="my_option.2">False</option>
  </select>
</div>';
is_html( $rendered, $expected, 'output from BoolSelect field' );

done_testing;
