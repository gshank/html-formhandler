package HTML::FormHandler::Test;
# ABSTRACT: provides is_html method used in tests
use strict;
use warnings;
use HTML::TreeBuilder;
use Test::Builder::Module;
use base 'Test::Builder::Module';
our @EXPORT = ('is_html');

sub is_html {
    my ( $got, $expected, $message ) = @_;
    my $t1 = HTML::TreeBuilder->new;
    my $t2 = HTML::TreeBuilder->new;

    $t1->parse($got);
    $t1->eof;
    $t2->parse($expected);
    $t2->eof;

    my $out1 = $t1->as_XML;
    my $out2 = $t2->as_XML;
    $t1->delete;
    $t2->delete;

    my $tb = HTML::FormHandler::Test->builder;
    return $tb->is_eq($out1, $out2, $message);
}

1;
