use strict;
use warnings;
use Test::More;
use Test::Exception;

use lib 't/lib';

use HTML::FormHandler::Field::Text;

{

    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'testform' );
    has_field 'test_field' => (
        size  => 20,
        label => 'TEST',
        id    => 'f99',
    );
    has_field 'number';
    has_field 'fruit'      => ( type => 'Select' );
    has_field 'vegetables' => ( type => 'Multiple' );
    has_field 'opt_in'     => (
        type    => 'Select',
        widget  => 'radio_group',
        options => [
            {
                value => 'no & never',
                label => 'No & Never',
                # this can depend on something else,
                # with fixed value will cause field be
                # always checked even after process
                checked => 1,
            },
            { value => '"yes"', label => 'Yes' },
        ]
    );
    has_field 'comedians' => (
        type => 'Multiple',
        widget => 'checkbox_group',
        options => [
            { value => 'keaton', label => 'Buster Keaton'},
            { value => 'chaplin', label => 'Charly Chaplin'},
            { value => 'laurel & hardy', label => 'Stan Laurel & Oliver Hardy' },
        ],
    );
    has_field 'active'     => ( type => 'Checkbox' );
    has_field 'comments'   => ( type => 'TextArea' );
    has_field 'hidden'     => ( type => 'Hidden' );
    has_field 'selected'   => ( type => 'Boolean' );
    has_field 'start_date' => ( type => 'DateTime' );
    has_field 'start_date.month' => (
        type        => 'Integer',
        range_start => 1,
        range_end   => 12
    );
    has_field 'start_date.day' => (
        type        => 'Integer',
        range_start => 1,
        range_end   => 31
    );
    has_field 'start_date.year' => (
        type        => 'Integer',
        range_start => 2000,
        range_end   => 2020
    );

    has_field 'two_errors' => (
        apply => [
            { check => [], message => 'First constraint error' },
            { check => [], message => 'Second constraint error' }
        ]
    );

    has_field 'submit' => ( type => 'Submit', value => '>>> Update' );
    has_field 'reset' => ( type => 'Reset', value => '<<< Reset' );

    has '+dependency' => (
        default => sub {
            [ [ 'start_date.month', 'start_date.day', 'start_date.year' ] ];
        }
    );
    has_field 'no_render' => ( widget => 'no_render' );
    has_field 'plain' => ( widget_wrapper => 'None' );

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
ok( $form, 'create form' );

my $output10 = $form->field('opt_in')->render;
is(
    $output10, '
<div><label class="label" for="opt_in">Opt in: </label> <br /><input type="radio" value="no &amp; never" name="opt_in" id="opt_in.0" checked="checked" />No &amp; Never<br /><input type="radio" value="&quot;yes&quot;" name="opt_in" id="opt_in.1" />Yes<br /></div>
', 'output from radio group'
);

my $output12 = $form->field('comedians')->render;
is(
    $output12, '
<div><label class="label" for="comedians">Comedians: </label> <br /><input type="checkbox" value="keaton" name="comedians" id="comedians.0" />Buster Keaton<br /><input type="checkbox" value="chaplin" name="comedians" id="comedians.1" />Charly Chaplin<br /><input type="checkbox" value="laurel &amp; hardy" name="comedians" id="comedians.2" />Stan Laurel &amp; Oliver Hardy<br /></div>
', 'output from checkbox group'
);

my $params = {
    test_field         => 'something',
    number             => 0,
    fruit              => '<oranges>',
    vegetables         => [ 'broccoli', '& peas' ],
    active             => 'now',
    comments           => 'Four score and seven years ago...</textarea>',
    hidden             => '1234',
    selected           => '1',
    'start_date.month' => '7',
    'start_date.day'   => '14',
    'start_date.year'  => '2006',
    two_errors         => 'aaa',
    opt_in             => 'no & never',
    plain              => 'No divs!!',
    comedians         => [ 'chaplin', 'laurel & hardy' ],
};

$form->process($params);

is(
    $form->field('number')->render,
    '
<div><label class="label" for="number">Number: </label><input type="text" name="number" id="number" value="0" /></div>
',
    "value '0' is rendered"
);

my $output1 = $form->field('test_field')->render;
is(
    $output1,
    '
<div><label class="label" for="f99">TEST: </label><input type="text" name="test_field" id="f99" size="20" value="something" /></div>
',
    'output from text field'
);

my $output2 = $form->field('fruit')->render;
is(
    $output2,
    '
<div><label class="label" for="fruit">Fruit: </label><select name="fruit" id="fruit"><option value="&quot;apples&quot;" id="fruit.0">&quot;apples&quot;</option><option value="&lt;oranges&gt;" id="fruit.1" selected="selected">&lt;oranges&gt;</option><option value="&amp;kiwi&amp;" id="fruit.2">&amp;kiwi&amp;</option></select></div>
',
    'output from select field'
);

my $output3 = $form->field('vegetables')->render;
is(
    $output3,
    '
<div><label class="label" for="vegetables">Vegetables: </label><select name="vegetables" id="vegetables" multiple="multiple" size="5"><option value="&lt;lettuce&gt;" id="vegetables.0">&lt;lettuce&gt;</option><option value="broccoli" id="vegetables.1" selected="selected">broccoli</option><option value="carrots" id="vegetables.2">carrots</option><option value="&amp; peas" id="vegetables.3" selected="selected">&amp; peas</option></select></div>
',
    'output from select multiple field'
);

my $output4 = $form->field('active')->render;
is(
    $output4,
    '
<div><label class="label" for="active">Active: </label><input type="checkbox" name="active" id="active" value="1" /></div>
',
    'output from checkbox field'
);

my $output5 = $form->field('comments')->render;
is(
    $output5,
    '
<div><label class="label" for="comments">Comments: </label><textarea name="comments" id="comments" rows="5" cols="10">Four score and seven years ago...&lt;/textarea&gt;</textarea></div>
',
    'output from textarea'
);

my $output6 = $form->field('hidden')->render;
is(
    $output6,
    '
<input type="hidden" name="hidden" id="hidden" value="1234" />
',
    'output from hidden field'
);

my $output7 = $form->field('selected')->render;
is(
    $output7,
    '
<div><label class="label" for="selected">Selected: </label><input type="checkbox" name="selected" id="selected" value="1" checked="checked" /></div>
',
    'output from boolean'
);

my $output8 = $form->field('start_date')->render;
is(
    $output8,
    '
<div><fieldset class="start_date"><legend>Start date</legend>
<div><label class="label" for="start_date.month">Month: </label><input type="text" name="start_date.month" id="start_date.month" size="8" value="7" /></div>

<div><label class="label" for="start_date.day">Day: </label><input type="text" name="start_date.day" id="start_date.day" size="8" value="14" /></div>

<div><label class="label" for="start_date.year">Year: </label><input type="text" name="start_date.year" id="start_date.year" size="8" value="2006" /></div>
</fieldset></div>
',
    'output from DateTime'
);

my $output9 = $form->field('submit')->render;
is(
    $output9, '
<div><input type="submit" name="submit" id="submit" value="&gt;&gt;&gt; Update" /></div>
', 'output from Submit'
);
my $output9a = $form->field('reset')->render;
is(
    $output9a, '
<div><input type="reset" name="reset" id="reset" value="&lt;&lt;&lt; Reset" /></div>
', 'output from Reset'
);


$output10 = $form->field('opt_in')->render;
is(
    $output10, '
<div><label class="label" for="opt_in">Opt in: </label> <br /><input type="radio" value="no &amp; never" name="opt_in" id="opt_in.0" checked="checked" />No &amp; Never<br /><input type="radio" value="&quot;yes&quot;" name="opt_in" id="opt_in.1" />Yes<br /></div>
', 'output from radio group'
);

my $output11 = $form->render_start;
is(
    $output11, '<form id="testform" method="post" >
<fieldset class="main_fieldset">', 'Form start OK'
);

$output12 = $form->field('comedians')->render;
is(
    $output12,
    '
<div><label class="label" for="comedians">Comedians: </label> <br /><input type="checkbox" value="keaton" name="comedians" id="comedians.0" />Buster Keaton<br /><input type="checkbox" value="chaplin" name="comedians" id="comedians.1" checked="checked" />Charly Chaplin<br /><input type="checkbox" value="laurel &amp; hardy" name="comedians" id="comedians.2" checked="checked" />Stan Laurel &amp; Oliver Hardy<br /></div>
',
    'output from checkbox group'
);

my $output = $form->render;
ok( $output, 'get rendered output from form' );

is( $form->field('no_render')->render, '', 'no_render' );

is( $form->field('plain')->render, '<input type="text" name="plain" id="plain" value="No divs!!" />', 'renders without wrapper');


{

    package Test::Widgets;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_name_space' => ( default => sub { ['Widget'] } );

    has_field 'alpha' => ( widget => 'test_widget' );
    has_field 'omega' => ( widget => 'Omega' );
    has_field 'iota';
}

$form = Test::Widgets->new;
ok( $form, 'get form with custom widgets' );
is( $form->field('alpha')->render, '<p>The test succeeded.</p>', 'alpha rendered ok' );
is( $form->field('omega')->render, '<h1>You got here!</h1>',     'omega rendered ok' );

{

    package Test::NoWidget;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_name_space' => ( default => sub { ['Widget'] } );
    has_field 'no_widget' => ( widget => 'no_widget' );
}
dies_ok( sub { Test::NoWidget->new }, 'dies on no widget' );
throws_ok( sub { Test::NoWidget->new }, qr/Can't find /, 'no widget throws message' );

$form = Test::Form->new( widget_form => 'Table', widget_wrapper => 'Table' );
ok( $form->can('render'), 'form has table widget' );
like( $form->field('number')->render, qr/<td>/, 'field has table wrapper');
$form->process($params);
my $outputT = $form->render;
ok( $outputT, 'output from table rendering' );

{

    package Test::Tags;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has '+widget_tags' => (
        default => sub {
            {
                wrapper_start => '<p>',
                wrapper_end   => '</p>',
            };
        }
    );
    has_field 'bar' => ( widget_tags => 
         {wrapper_start => '<span>', wrapper_end => '</span>'});
}

$form = Test::Tags->new;
$form->process( { foo => 'bar' } );
is( $form->field('foo')->render, '
<p><label class="label" for="foo">Foo: </label><input type="text" name="foo" id="foo" value="bar" /></p>
', 'renders with different tags');

is( $form->field('bar')->render, '
<span><label class="label" for="bar">Bar: </label><input type="text" name="bar" id="bar" value="" /></span>
', 'field renders with custom widget_tags' );

done_testing;
