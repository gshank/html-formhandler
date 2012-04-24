use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Theme::Basic;
    use Moose::Role;

    sub build_do_form_wrapper {1}
    sub build_form_tags {{  wrapper_tag => 'div' }}
    sub build_update_subfields {{
        all => { tags => { label_tag => 'span' } },
        by_flag => { 'compound' => { do_wrapper => 1, do_label => 1,
           tags => {  wrapper_tag => 'span' }}},
    }}
    sub html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        $attr->{class} = ['frm', 'ele'] if $type eq 'element';
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
  <span class="frm lbl">My comp</span>
  <div class="frm wrp">
    <span class="frm lbl">One</span>
    <input class="frm ele" type="text" name="my_comp.one" id="my_comp.one" value="" />
  </div>
  <div class="frm wrp">
    <span class="frm lbl">Two</span>
    <input class="frm ele" type="text" name="my_comp.two" id="my_comp.two" value="" />
  </div>
</span>';
is_html( $rendered, $expected, 'compound rendered ok' );

{
    package Test::DT;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_update_subfields {{ all => { tags => { label_after => ': ' }}}}
    has_field 'start_date' => ( type => 'DateTime', do_wrapper => 1, do_label => 1,
        tags => { wrapper_tag => 'fieldset' }, wrapper_class => 'start_date' );
    has_field 'start_date.month' => ( type => 'Integer', range_start => 1,
        range_end => 12 );
    has_field 'start_date.day' => ( type => 'Integer', range_start => 1,
        range_end => 31 );
    has_field 'start_date.year' => ( type => 'Integer', range_start => 2000,
        range_end => 2020 );
}

$form = Test::DT->new;
my $params = { 'start_date.month' => 7, 'start_date.day' => 14, 'start_date.year' => '2006' };
$form->process( $params );

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
