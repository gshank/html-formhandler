use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package HTML::FormHandler::Render::FFTheme;
    use Moose::Role;

    sub build_update_subfields {{ all => { tags => { no_wrapped_label => 1 } } }}
    sub html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        my $class = $attr->{class} || [];
        if( $type eq 'wrapper' ) {
            # this is not exactly like what FF does, but it's close
            push @$class, lc $field->type;
            push @$class, 'label' if $field->do_label;
            $attr->{class} = $class;
        }
        return $attr;
    }
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::FFTheme';

    has '+name' => ( default => 'test_form' );
    has '+action' => ( default => '/form' );
    has_field 'user' => ( label => 'Username' );
    has_field 'pass' => ( type => 'Password', label => 'Password' );
    has_field 'opt_in' => ( type => 'Checkbox',
        label => 'Opt in?',
    );
    has_field 'choose' => ( type => 'Select',
        label => 'Choose some',
        options => [ { label => 'blue', value => 1 }, { label => 'red', value => 2 }] );
    has_field 'submit' => ( type => 'Submit', value => "Save" );

}


my $expected =
'<form action="/form" method="post" id="test_form" >
  <div class="form_messages"></div>
  <div class="text label">
    <label for="user">Username</label>
    <input name="user" type="text" id="user" value="" />
  </div>
  <div class="password label">
    <label for="pass">Password</label>
    <input name="pass" id="pass" type="password" value="" />
  </div>
  <div class="checkbox label">
    <label for="opt_in">Opt in?</label>
    <input name="opt_in" id="opt_in" type="checkbox" value="1" />
  </div>
  <div class="select label">
    <label for="choose">Choose some</label>
    <select name="choose" id="choose">
      <option id="choose.0" value="1">blue</option>
      <option id="choose.1" value="2">red</option>
    </select>
  </div>
  <div class="submit">
    <input name="submit" id="submit" type="submit" value="Save" />
  </div>
</form>';

my $form = Test::Form->new;
$form->process;
my $rendered = $form->render;
is_html($rendered, $expected, 'renders ok' );

done_testing;
