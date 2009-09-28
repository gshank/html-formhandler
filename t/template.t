use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Differences;

use_ok('Template::Tiny');
use aliased 'Template::Tiny::Stash';

my $tt = Template::Tiny->new();

basic_text: {
    my $str = $tt->compile_tmpl(
        [[ TEXT => 'Hello one and all' ]],
    );

    my $expected = <<'END';
sub {
    my ($stash_a) = @_;
    my $out;
  $out .= 'Hello one and all';
}
END

    is $str, $expected, 'Basic Text works';
}

basic_var: {
    my $str = $tt->compile_tmpl(
        [[ VARS => ['albert'] ]],
    );

    my $expected = <<'END';
sub {
    my ($stash_a) = @_;
    my $out;
  $out .= $stash_a->get('albert');
}
END

    is $str, $expected, 'Basic Variable works';
}

basic_section: {
    my $str = $tt->compile_tmpl(
        [[ SECTION => "blog" ], [ 'END' ]],
    );
    
    my $expected = <<'END';
sub {
    my ($stash_a) = @_;
    my $out;
  for my $stash_b ( $stash_a->sections('blog') ) {
  }
}
END

    is $str, $expected, 'Basic Section works';
}

complex: {
    my $str = $tt->compile_tmpl(
        [
            [TEXT => 'hehehe sucka '],
            [VARS => ['name', 'escape_html']],
            [TEXT => "\n        "],
            [SECTION => 'foo'],
            [TEXT => ' '],
            [VARS => ['hehe']],
            [TEXT => ' '],
            ['END'],
        ],
    );

    my $expected = <<'END';
sub {
    my ($stash_a) = @_;
    my $out;
  $out .= 'hehehe sucka ';
  $out .= $stash_a->get('name', 'escape_html');
  $out .= '
        ';
  for my $stash_b ( $stash_a->sections('foo') ) {
  $out .= ' ';
  $out .= $stash_b->get('hehe');
  $out .= ' ';
  }
}
END


    is $str, $expected, 'Complex example works';
}

$tt = Template::Tiny->new();

my ($tl, $got);
basic_variable: {
    check('[% name %]', [[ VARS => ['name'] ]], 'Basic variable');
}

basic_plus_text: {
    check(
        'hhhmmm.... [% haha %]', 
        [[ TEXT => 'hhhmmm.... ' ], [ VARS => ['haha'] ]], 
        'Text plus basic var'
    );
}

basic_end_text: {
    check(
        '[% one_two %] bubba',
        [ [VARS => ['one_two'] ], [TEXT => ' bubba'] ],
        'Basic with text end'
    );
}

basic_with_filters: {
    check(
        '[% value | filter1 | filter2 %]', 
        [[ VARS => ['value', 'filter1', 'filter2'] ]], 
        'Filters'
    );
}

section: {
    check(
        '[% SECTION hehe %][% END %]',
        [[ SECTION => 'hehe' ], [ 'END' ]], 
        'Sections'
    );
}

include: {
    check(
        "[% INCLUDE 'hehe.html' %]",
        [[ INCLUDE => 'hehe.html' ]],
        'Include'
    );
}

complex: {
    check(
        'hehehe sucka [% name | escape_html %]
        [% SECTION foo %] [%hehe%] [% END %]',
        [
            [TEXT => 'hehehe sucka '],
            [VARS => ['name', 'escape_html']],
            [TEXT => "\n        "],
            [SECTION => 'foo'],
            [TEXT => ' '],
            [VARS => ['hehe']],
            [TEXT => ' '],
            ['END'],
        ],
        'Complex'
    );
}

sub check {
    my ($tpl, $ast, $cmt) = @_;
    my $got = $tt->parse_tmpl($tpl);
    cmp_deeply($got, $ast, $cmt);
}


basic: {
    my $stash = Stash->new();
    isa_ok($stash, 'Template::Tiny::Stash');
}

accessor: {
    my $stash = Stash->new({
        a => 1,    
    });

    is $stash->get('a'), 1, 'Basic stash retrieval';
}

sections: {
    my $stash  = Stash->new({});
    my $stash2 = Stash->new({});
    my $stash3 = Stash->new({});

    $stash->add_section('name', $stash2);
    $stash->add_section('name', $stash3);

    my @sections = $stash->sections('name');
    is scalar(@sections), 2, 'Correct number of sections';
    is_deeply [@sections], [$stash2, $stash3], 'Correct sections';
}

multi_sections: {
    my $stash  = Stash->new({});
    my $stash2 = Stash->new({});
    my $stash3 = Stash->new({});

    $stash->add_section('name', $stash2, $stash3);

    my @sections = $stash->sections('name');
    is scalar(@sections), 2, 'Correct number of sections';
    is_deeply [@sections], [$stash2, $stash3], 'Correct sections';
}

empty_section: {
    my $stash  = Stash->new({});

    $stash->add_section('name');

    my @sections = $stash->sections('name');
    is scalar(@sections), 1, 'Correct number of sections';
    is_deeply [@sections], [undef], 'Correct sections';
}


basic: {
    my $stash = Stash->new({
        name => 'Perl Hacker', title => 'paper',
    });

    my $tt = Template::Tiny->new({
        tmpl_include_path => ['t/tmpl'],
    });

    
    my $out = $tt->process_file('foo.tpl', $stash);
    my $expected = <<'END';

Hi Perl Hacker,

This is my paper

END
    is( $out, $expected, 'Full process');
}

$DB::single=1;

nested_sections: {
    my $stash = Stash->new({
        name => 'Charlie', interest => 'movies',
    });

    my $item1 = Stash->new({ item => 'Happy Gilmore' });
    my $item2 = Stash->new({ item => 'Care Bears' });
    
    $stash->add_section('items', $item1);
    $stash->add_section('items', $item2);

    $stash->add_section('possible_geek');

    my $tt = Template::Tiny->new({
        tmpl_include_path => ['t/tmpl'],
    });

    my $out = $tt->process_file('nested.tpl', $stash );
    my $expected = <<'END';
<html>
  <head><title>Howdy Charlie</title></head>
  <body>
    <p>My favourite things, movies!</p>
    <ul>
      
        <li>Happy Gilmore</li>
      
        <li>Care Bears</li>
      
    </ul>

    
        <span>I likes DnD...</span>
    
  </body>
</html>
END

    eq_or_diff( $out, $expected, 'More complex example' );
}

horror: {    
    my $stash = Stash->new({
        name => 'Perl Hacker',
    });

    my $tt = Template::Tiny->new({
        tmpl_include_path => ['t/tmpl'],
    });

    my $out = $tt->process_file('horror.tpl', $stash);
    my $expected = <<'END';

~`@#$%^&*()-_=+{[]}\|;:"'<,.>?/

Perl Hacker
END
    is $out, $expected, 'Horror process';
}

# template strings

my $template = <<END;
<div class="[% css_class %]">
<input type="text">[% fif %]</input>
END

my $out = $tt->process_str('input' => $template, Stash->new({css_class => 'cinput',
            fif => 'Testing'}));
ok( $out, 'processed string template' );
my $processed = '<div class="cinput">
<input type="text">Testing</input>';
is( $out, $processed, 'output ok');

$out = $tt->process_str('my_tmpl' => $template, {css_class => 'cinput',
             fif => 'Testing'});
is( $out, $processed, 'output ok');

$template = <<END;
TEST: [% some_var %] [% IF reason %]reason="[% reason %]"[% END %]
stop test
END

$tt->add_template('test_if', $template);
ok( $tt->_has_template('test_if'), 'template has been added' );
$out = $tt->process( 'test_if', { some_var => "Here it is" } );
ok( $out, 'got output' );

my $widget = <<'END';
<input type="text" name="[% html_name %]" id="[% id %]" 
    [% IF size %] size="[% size %]"[% END %] 
    [% IF maxlength %] maxlength="[% maxlength %]"[% END %]
    value="[% fif %]">
END

$DB::single=1;
$tt->add_template('widget', $widget);
ok( $tt->_has_template('widget'), 'widget template added' );
$out = $tt->process('widget', {
        html_name => 'test_field',
        id => 'abc1',
        size => 40,
        maxlength => 50,
        fif => 'my_test',
    });
ok( $out, 'got output' );
my $output = 
'<input type="text" name="test_field" id="abc1" 
     size="40" 
     maxlength="50"
    value="my_test">';
is( $out, $output, 'output matches' );



done_testing;

