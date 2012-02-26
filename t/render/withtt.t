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

use_ok('HTML::FormHandler::Render::WithTT');
use_ok('HTML::FormHandler::Render::Simple');

my $dir = File::ShareDir::dist_dir('HTML-FormHandler') . '/templates/';
ok( $dir, 'found template dir' );

{
    package Test::Form::WithTT::Role;
    use Moose::Role;
    with 'HTML::FormHandler::Render::WithTT' =>
        { -excludes => [ 'build_tt_template', 'build_tt_include_path' ] };
    sub build_tt_template     {'form/form.tt'}
    sub build_tt_include_path { ['share/templates'] }
}

{
    package Test::Form::WithTT::FormInOne::Role;
    use Moose::Role;
    with 'HTML::FormHandler::Render::WithTT' =>
        { -excludes => [ 'build_tt_template', 'build_tt_include_path' ] };
    sub build_tt_template     {'form/form_in_one.tt'}
    sub build_tt_include_path { ['share/templates'] }
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'submit' => ( type => 'Submit', widget_wrapper => 'None' );
    has_field 'foo';
=pod
    has_field 'bar';
    has_field 'fubar' => ( type => 'Compound',
        widget_wrapper => 'Fieldset',
        do_wrapper => 1,
        wrapper_attr => { class => 'fubar' },
    );
    has_field 'fubar.name';
    has_field 'fubar.country';
=cut
    has_field 'opt_in' => ( type => 'Checkbox', label => 'XXXX', default => 1,
        tags => { no_wrapped_label => 1 },
    );
=pod
    has_field 'choose' => ( type => 'Select', default => 2 );
    has_field 'picksome' => ( type => 'Multiple', default => [1,2] );
    has_field 'click' => ( type => 'Button' );
    has_field 'reset' => ( type => 'Reset' );
    has_field 'hidden' => ( type => 'Hidden' );
    has_field 'mememe' => ( type => 'Multiple', widget => 'RadioGroup', default => [2] );
    has_field 'notes' => ( type => 'TextArea', cols => 30, rows => 4 );
    has_field 'addresses' => ( type => 'Repeatable', widget_wrapper => 'Fieldset',
        tags => {  wrapper_tag => 'fieldset' },
    );
    has_field 'addresses.street' => ( type => 'Text' );
    has_field 'addresses.city' => ( type => 'Text' );
    has_field 'pw' => ( type => 'Password' );
=cut
    has_field 'categories' => ( type => 'Multiple', widget => 'CheckboxGroup', default => [1] );

    sub options_choose {
        return (
            1   => 'apples',
            2   => 'oranges',
            3   => 'kiwi',
        );
    }

    sub options_picksome {
        return (
            1   => 'blue',
            2   => 'red',
            3   => 'orange',
       );
    }
    sub options_mememe {
        return (
            1   => 'me',
            2   => 'my',
            3   => 'mine',
        );
    }
    sub options_categories {
        return (
            1  => 'fun',
            2  => 'work',
            3  => 'boring',
        );
    }
    sub html_attributes {
        my ( $self, $field, $type, $attr ) = @_;
        $attr->{id} = 'wr_' . $field->name if $type eq 'wrapper';
        return $attr;
    }
}

my $rendered_via_tt;
{
    my $form = Test::Form->new_with_traits( traits => ['Test::Form::WithTT::Role'], name => 'test_tt' );
    ok( $form, 'form builds' );
    ok( $form->tt_include_path, 'tt include path' );
    $rendered_via_tt = $form->tt_render;
    ok($rendered_via_tt, 'form tt renders' );
}

my $rendered_via_widget;
{
    my $form = Test::Form->new(name => 'test_tt');
    ok( $form, 'form builds' );
    $rendered_via_widget = $form->render;
    ok($rendered_via_widget, 'form simple renders' );
}

my $rendered_via_tt_in_one;
{
    my $form = Test::Form->new_with_traits( traits => ['Test::Form::WithTT::FormInOne::Role'], name => 'test_tt' );
    ok( $form, 'form builds' );
    ok( $form->tt_include_path, 'tt include path' );
    $rendered_via_tt_in_one = $form->tt_render;
    ok($rendered_via_tt_in_one, 'form tt renders' );
}


is_html($rendered_via_tt, $rendered_via_widget, 'tt rendering matches widget rendering' );
is_html($rendered_via_tt, $rendered_via_tt_in_one, 'tt rendering matches tt-in-one rendering' );

done_testing;
exit;

my $tt = HTML::TreeBuilder->new_from_content($rendered_via_tt);
my $widget = HTML::TreeBuilder->new_from_content($rendered_via_widget);
my $tt_ele = $tt->find_by_attribute('name', 'submit');
my $wt_ele = $widget->find_by_attribute('name', 'submit');
is_html($tt_ele->as_HTML, $wt_ele->as_HTML, "submit matches" );
my @elements = ('foo', 'bar', 'opt_in', 'choose', 'picksome' );
check_elements( "wr_" . $_ ) for @elements;

sub check_elements {
    my $ele = shift;
    my $tt_ele = $tt->find_by_attribute('id', $ele);
    my $wt_ele = $widget->find_by_attribute('id', $ele);
    is_html($tt_ele->as_HTML, $wt_ele->as_HTML, "$ele matches" );
}

done_testing;
