use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Differences;

{
   package Template::Tiny;
   use Moose;
   with 'HTML::FormHandler::Template';

}

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

    is $str, $expected, q{Basic Text works};
}

basic_var: {
    my $str = $tt->compile_tmpl(
        [[ VARS => [qw(albert)] ]],
    );

    my $expected = <<'END';
sub {
    my ($stash_a) = @_;
    my $out;
  $out .= $stash_a->get(qw(albert));
}
END

    is $str, $expected, q{Basic Variable works};
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

    is $str, $expected, q{Basic Section works};
}

complex: {
    my $str = $tt->compile_tmpl(
        [
            [TEXT => 'hehehe sucka '],
            [VARS => [qw(name escape_html)]],
            [TEXT => "\n        "],
            [SECTION => 'foo'],
            [TEXT => ' '],
            [VARS => [qw(hehe)]],
            [TEXT => ' '],
            ['END'],
        ],
    );

    my $expected = <<'END';
sub {
    my ($stash_a) = @_;
    my $out;
  $out .= 'hehehe sucka ';
  $out .= $stash_a->get(qw(name escape_html));
  $out .= '
        ';
  for my $stash_b ( $stash_a->sections('foo') ) {
  $out .= ' ';
  $out .= $stash_b->get(qw(hehe));
  $out .= ' ';
  }
}
END


    is $str, $expected, q{Complex example works};
}

$tt = Template::Tiny->new();

my ($tl, $got);
basic_variable: {
    check(q{[% name %]}, [[ VARS => [qw(name)] ]], q{Basic variable});
}

basic_plus_text: {
    check(
        q{hhhmmm.... [% haha %]}, 
        [[ TEXT => 'hhhmmm.... ' ], [ VARS => [qw(haha)] ]], 
        q{Text plus basic var}
    );
}

basic_end_text: {
    check(
        q{[% one_two %] bubba},
        [ [VARS => [qw(one_two)] ], [TEXT => ' bubba'] ],
        q{Basic with text end}
    );
}

basic_with_filters: {
    check(
        q{[% value | filter1 | filter2 %]}, 
        [[ VARS => [qw(value filter1 filter2)] ]], 
        q{Filters}
    );
}

section: {
    check(
        q{[% SECTION hehe %][% END %]},
        [[ SECTION => 'hehe' ], [ 'END' ]], 
        q{Sections}
    );
}

include: {
    check(
        q{[% INCLUDE 'hehe.html' %]},
        [[ INCLUDE => q{hehe.html} ]],
        q{Include}
    );
}

complex: {
    check(
        q{hehehe sucka [% name | escape_html %]
        [% SECTION foo %] [%hehe%] [% END %]},
        [
            [TEXT => 'hehehe sucka '],
            [VARS => [qw(name escape_html)]],
            [TEXT => "\n        "],
            [SECTION => 'foo'],
            [TEXT => ' '],
            [VARS => [qw(hehe)]],
            [TEXT => ' '],
            ['END'],
        ],
        q{Complex}
    );
}

sub check {
    my ($tpl, $ast, $cmt) = @_;
    my $got = $tt->parse_tmpl($tpl);
    cmp_deeply($got, $ast, $cmt);
}

use_ok('HTML::FormHandler::Template::Stash');

basic: {
    my $stash = HTML::FormHandler::Template::Stash->new();
    isa_ok($stash, 'HTML::FormHandler::Template::Stash');
}

accessor: {
    my $stash = HTML::FormHandler::Template::Stash->new({
        a => 1,    
    });

    is $stash->get('a'), 1, q{Basic stash retrieval};
}

sections: {
    my $stash  = HTML::FormHandler::Template::Stash->new({});
    my $stash2 = HTML::FormHandler::Template::Stash->new({});
    my $stash3 = HTML::FormHandler::Template::Stash->new({});

    $stash->add_section('name', $stash2);
    $stash->add_section('name', $stash3);

    my @sections = $stash->sections('name');
    is scalar(@sections), 2, q{Correct number of sections};
    is_deeply [@sections], [$stash2, $stash3], q{Correct sections};
}

multi_sections: {
    my $stash  = HTML::FormHandler::Template::Stash->new({});
    my $stash2 = HTML::FormHandler::Template::Stash->new({});
    my $stash3 = HTML::FormHandler::Template::Stash->new({});

    $stash->add_section('name', $stash2, $stash3);

    my @sections = $stash->sections('name');
    is scalar(@sections), 2, q{Correct number of sections};
    is_deeply [@sections], [$stash2, $stash3], q{Correct sections};
}

empty_section: {
    my $stash  = HTML::FormHandler::Template::Stash->new({});

    $stash->add_section('name');

    my @sections = $stash->sections('name');
    is scalar(@sections), 1, q{Correct number of sections};
    is_deeply [@sections], [undef], q{Correct sections};
}


basic: {
    my $stash = HTML::FormHandler::Template::Stash->new({
        name => 'Perl Hacker', title => 'paper',
    });

    my $tt = Template::Tiny->new({
        tmpl_include_path => [q{t/tmpl}],
    });

    
    my $out = $tt->process_tmpl_file('foo.tpl', $stash);
    my $expected = <<'END';

Hi Perl Hacker,

This is my paper

END
    is $out, $expected, q{Full process};
}

nested_sections: {
    my $stash = HTML::FormHandler::Template::Stash->new({
        name => 'Charlie', interest => 'movies',
    });

    my $item1 = HTML::FormHandler::Template::Stash->new({ item => 'Happy Gilmore' });
    my $item2 = HTML::FormHandler::Template::Stash->new({ item => 'Care Bears' });
    
    $stash->add_section('items', $item1);
    $stash->add_section('items', $item2);

    $stash->add_section('possible_geek');

    my $tt = Template::Tiny->new({
        tmpl_include_path => [q{t/tmpl}],
    });

    my $out = $tt->process_tmpl_file('nested.tpl', $stash );
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

    eq_or_diff $out, $expected, q{More complex example};
}

horror: {    
    my $stash = HTML::FormHandler::Template::Stash->new({
        name => 'Perl Hacker',
    });

    my $tt = Template::Tiny->new({
        tmpl_include_path => [q{t/tmpl}],
    });

    my $out = $tt->process_tmpl_file('horror.tpl', $stash);
    my $expected = <<'END';

~`@#$%^&*()-_=+{[]}\|;:"'<,.>?/

Perl Hacker
END
    is $out, $expected, q{Horror process};
}

# template stringsl

done_testing;

