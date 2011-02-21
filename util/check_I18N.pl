#!/usr/bin/env perl

#============================================================
# util/check_I18N.pl
#
# pull messages file, and check the I18N lexicons for
# coverage
#============================================================

use strict;
use warnings;

use utf8;
use Encode;
use Cwd;
use File::Find;
use Class::Load ':all';
use Data::Dumper;
use lib ( getcwd() . '/lib');
use HTML::FormHandler::I18N;

my @directories = ( getcwd() . "/lib/HTML/FormHandler/I18N" );
my @lexicons;
find(\&wanted, @directories);

my $infile = getcwd() . '/util/messages';
open( my $fh, '<:utf8', $infile ) or die "Unable to open $infile";
my $line = 1;
my @lines = <$fh>;
my $msgs_from_file = join( ' ', @lines );
my $messages = eval $msgs_from_file;
my @builtin_messages = map { values %{$_} } (map { values %{$_}} @$messages);

binmode STDOUT, ":utf8";
foreach my $lexicon (@lexicons) {
    print "\n\n========== $lexicon ================\n";
    my $lh = HTML::FormHandler::I18N->get_handle($lexicon);
    foreach my $msg (@builtin_messages) {
        my $translated = $lh->maketext($msg, '[_1]', '[_2]');
        print $msg, "  ==>  ", $translated, "\n";
    }

}

# you can pull in the arrayref of hashrefs that's written out
#my $recovered = eval $output;

sub wanted {
    my $type = $_;
    return if $type eq '.';
    $type =~ s/\.pm$//;
    my $class = "HTML::FormHandler::I18N::$type";
    if( try_load_class( $class ) ) {
        push @lexicons, $type;
        print "$type\n";
    }
    else {
        print "did not load $type\n";
    }

}
