use strict;
use warnings;
use Test::More;
use File::ShareDir;
use HTML::TreeBuilder;
use HTML::FormHandler::Test;

BEGIN {
    plan skip_all => 'Install Template Toolkit to test Render::WithTT'
       unless eval { require Template };
}


{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::WithTT' =>
        { -excludes => [ 'build_tt_template', 'build_tt_include_path' ] };
    sub build_tt_template     {'form/form22.tt'}
    sub build_tt_include_path { ['share/templates'] }

    has_field 'foo';
    has_field 'opt_in' => ( type => 'Checkbox' );
    has_field 'choose' => ( type => 'Select', default => 2 );
    sub options_choose {
        return (
            1   => 'apples',
            2   => 'oranges',
            3   => 'kiwi',
        );
    }
    has_field 'my_hidden' => ( type => 'Hidden' );
    has_field 'submit' => ( type => 'Submit' );
}

my $form = Test::Form->new;
ok( $form, 'form builds' );
my $rendered = $form->tt_render;
ok($rendered, 'form tt renders' );
my $expected = '
<form class="xxx www">
  <div class="c23 a44">
    <label>Foo</label><input class="c123 ty63" id="foo" name="foo" type="text" value="" />
  </div><div class="x33 y55">
    <label class="muha" for="opt_in">Opt in?</label><input class="v22 dg34" id="opt_in" name="opt_in" type="checkbox" value="1" />
  </div>
  <div class="select p55">
    <select class="sw11" id="choose" name="choose">
      <option id="choose.0" value="1">apples</option>
      <option id="choose.1" selected="selected" value="2">oranges</option>
      <option id="choose.2" value="3">kiwi</option>
    </select>
  </div>
  <div classs="c23 a44">
    <input class="ghty" id="submit" name="submit" type="submit" value="Save" />
  </div>
  <input id="hid12" name="my_hidden" type="hidden" value="" />
</form>
';
is_html( $rendered, $expected);

done_testing;
