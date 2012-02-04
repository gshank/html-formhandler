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
        widget => 'checkbox_group',
        options => [
            { value => 'keaton', label => 'Buster Keaton'},
            { value => 'chaplin', label => 'Charly Chaplin'},
            { value => 'laurel & hardy', label => 'Stan Laurel & Oliver Hardy' },
        ],
    );
}
my $form = Test::Form->new;
$form->process;

my $expected = '
<div>
  <label for="comedians">Comedians</label> <br />
  <input type="checkbox" value="keaton" name="comedians" id="comedians.0" />Buster Keaton<br />
  <input type="checkbox" value="chaplin" name="comedians" id="comedians.1" />Charly Chaplin<br />
  <input type="checkbox" value="laurel &amp; hardy" name="comedians" id="comedians.2" />Stan Laurel &amp; Oliver Hardy<br />
</div>';
is_html( $form->field('comedians')->render, $expected, 'output from checkbox group');
my $params = {
    comedians          => [ 'chaplin', 'laurel & hardy' ],
};
$form->process($params);
my $rendered = $form->field('comedians')->render;
$expected =
'<div>
  <label for="comedians">Comedians</label> <br />
  <input type="checkbox" value="keaton" name="comedians" id="comedians.0" />Buster Keaton<br />
  <input type="checkbox" value="chaplin" name="comedians" id="comedians.1" checked="checked" />Charly Chaplin<br />
  <input type="checkbox" value="laurel &amp; hardy" name="comedians" id="comedians.2" checked="checked" />Stan Laurel &amp; Oliver Hardy<br />
</div>';
is_html( $rendered, $expected, 'output from checkbox group' );

done_testing;
