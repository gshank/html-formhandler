use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

use_ok( 'HTML::FormHandler::Field::Submit' );

my $field = HTML::FormHandler::Field::Submit->new(name => 'submit');
$field->build_result;
is( $field->value, 'Save', 'get right value');
ok( $field->result, 'returns result');

{
   package Test::Submit;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::Simple';

   has '+name' => (default => 'test_submit');
   has_field 'some_field';
   has_field 'submit' => ( type => 'Submit', value => 'Submit' );
}

my $form = Test::Submit->new;
ok( $form, 'get form');
my $params = { some_field => 'test' };
$form->process($params);
my $result = $form->result;
is( $result->num_results, 2, 'two results');
is( $form->field('submit')->input, undef, 'no input for submit field');
$form->process( { some_field => 'test', submit => 'Submit' } );
is( $form->field('submit')->input, 'Submit', 'input for submit field');
my $rendered = $form->render;
is_html( $rendered,
'<form id="test_submit" method="post">
  <div>
    <label for="some_field">Some field</label>
    <input type="text" name="some_field" id="some_field" value="test" />
  </div>
  <div>
    <input type="submit" name="submit" id="submit" value="Submit" />
  </div>
</form>',
'form renders');


done_testing;
