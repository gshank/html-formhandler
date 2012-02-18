use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'comedians' => (
        type => 'Multiple',
        widget => 'CheckboxGroup',
        options => [
            { value => 'keaton', label => 'Buster Keaton'},
            { value => 'chaplin', label => 'Charly Chaplin'},
            { value => 'laurel & hardy', label => 'Stan Laurel & Oliver Hardy' },
        ],
    );
    has_field 'fruit' => (
        type => 'Multiple',
        widget => 'CheckboxGroup',
        tags => { inline => 1 },
        options => [
            { value => 1, label => 'Apples' },
            { value => 2, label => 'Oranges' },
            { value => 3, label => 'Pears' },
        ],
    );

}
my $form = Test::Form->new;
$form->process;

my $expected = '
<div>
  <label for="comedians">Comedians</label>
  <label class="checkbox" for="comedians.0">
    <input type="checkbox" value="keaton" name="comedians" id="comedians.0" />
    Buster Keaton
  </label>
  <label class="checkbox" for="comedians.1">
    <input type="checkbox" value="chaplin" name="comedians" id="comedians.1" />
    Charly Chaplin
  </label>
  <label class="checkbox" for="comedians.2">
    <input type="checkbox" value="laurel &amp; hardy" name="comedians" id="comedians.2" />
    Stan Laurel &amp; Oliver Hardy
  </label>
</div>';
my $rendered = $form->field('comedians')->render;
is_html( $rendered, $expected, 'output from checkbox group');

$expected =
'<div>
  <label for="fruit">Fruit</label>
  <label class="checkbox inline" for="fruit.0">
    <input type="checkbox" value="1" name="fruit" id="fruit.0" />
    Apples
  </label>
  <label class="checkbox inline" for="fruit.1">
    <input type="checkbox" value="2" name="fruit" id="fruit.1" />
    Oranges
  </label>
  <label class="checkbox inline" for="fruit.2">
    <input type="checkbox" value="3" name="fruit" id="fruit.2" />
    Pears
  </label>
</div>';
$rendered = $form->field('fruit')->render;
is_html( $rendered, $expected, 'output from inline checkbox group' );

my $params = {
    comedians          => [ 'chaplin', 'laurel & hardy' ],
};
$form->process($params);
$rendered = $form->field('comedians')->render;
$expected =
'<div>
  <label for="comedians">Comedians</label>
  <label class="checkbox" for="comedians.0">
    <input type="checkbox" value="keaton" name="comedians" id="comedians.0" />
    Buster Keaton
  </label>
  <label class="checkbox" for="comedians.1">
    <input type="checkbox" value="chaplin" name="comedians" id="comedians.1" checked="checked" />
    Charly Chaplin
  </label>
  <label class="checkbox" for="comedians.2">
    <input type="checkbox" value="laurel &amp; hardy" name="comedians" id="comedians.2" checked="checked" />
    Stan Laurel &amp; Oliver Hardy
  </label>
</div>';
is_html( $rendered, $expected, 'output from checkbox group' );

done_testing;
