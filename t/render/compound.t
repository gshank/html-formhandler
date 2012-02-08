use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Theme::Basic;
    use Moose::Role;
    sub build_widget_tags {
        {
            form_wrapper => 1,
            form_wrapper_tag => 'div',
            label_tag => 'span',
            by_flag => {
                'compound' => { wrapper => 1, wrapper_tag => 'span' },
            }
        }
    }
    sub field_html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        $attr->{class} = ['frm', 'ele'] if $type eq 'input';
        $attr->{class} = ['frm', 'lbl'] if $type eq 'label';
        $attr->{class} = ['frm', 'wrp'] if $type eq 'wrapper';
        return $attr;
    }
}
{
    package MyApp::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'MyApp::Form::Theme::Basic';

    has_field 'my_comp' => ( type => 'Compound' );
    has_field 'my_comp.one';
    has_field 'my_comp.two';
    has_field 'my_text' => ( type => 'Text' );
}

my $form = MyApp::Form->new;
my $rendered = $form->field('my_comp')->render;
my $expected =
'<span class="frm wrp">
  <span class="frm lbl" for="my_comp">My comp</span>
  <div class="frm wrp">
    <span class="frm lbl" for="my_comp.one">One</span>
    <input class="frm ele" type="text" name="my_comp.one" id="my_comp.one" value="" />
  </div>
  <div class="frm wrp">
    <span class="frm lbl" for="my_comp.two">Two</span>
    <input class="frm ele" type="text" name="my_comp.two" id="my_comp.two" value="" />
  </div>
</span>';
is_html( $rendered, $expected, 'compound rendered ok' );

{
    package Test::DT;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_widget_tags {{ label_after => ': ' }}
    has_field 'start_date' => ( type => 'DateTime', widget_tags => { wrapper => 1,
        wrapper_tag => 'fieldset' }, wrapper_class => 'start_date' );
    has_field 'start_date.month' => ( type => 'Integer', range_start => 1,
        range_end => 12 );
    has_field 'start_date.day' => ( type => 'Integer', range_start => 1,
        range_end => 31 );
    has_field 'start_date.year' => ( type => 'Integer', range_start => 2000,
        range_end => 2020 );
}

$form = Test::DT->new;

$rendered = $form->field('start_date')->render;
is_html( $rendered,
'<fieldset class="start_date"><legend>Start date</legend>
  <div>
    <label for="start_date.month">Month: </label>
    <input type="text" name="start_date.month" id="start_date.month" size="8" value="7" />
  </div>
  <div>
    <label for="start_date.day">Day: </label>
    <input type="text" name="start_date.day" id="start_date.day" size="8" value="14" />
  </div>
  <div>
    <label for="start_date.year">Year: </label>
    <input type="text" name="start_date.year" id="start_date.year" size="8" value="2006" />
  </div>
</fieldset>',
   'output from DateTime' );

done_testing;
