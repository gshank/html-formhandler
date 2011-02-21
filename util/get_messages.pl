#!/usr/bin/env perl

#============================================================
# util/get_messages.pl
#
# This is a utility to pull all of the messages out of the
# FormHandler fields (and the Types package), for easy
# updating of I18N files.
#
# Writes out file util/messages that contains Dumper
# output for current messages, so that changes to messages
# can be tracked.
#
# Could also be used to construct customized messages in the
# form.
#============================================================

use strict;
use warnings;

use Cwd;
use File::Find;
use Class::Load ':all';
use Data::Dumper;
use lib ( getcwd() . '/lib');

my @directories = ( getcwd() . "/lib/HTML/FormHandler/Field" );
my @field_types;
find(\&wanted, @directories);

# get base Field class messages
my $base_messages = $HTML::FormHandler::Field::class_messages;

# get messages from Types module
use HTML::FormHandler::Types;
my $type_messages = $HTML::FormHandler::Types::class_messages;
my $all_messages = [ { 'Field' => { %$base_messages } },
                     { 'Types' => { %$type_messages } }];

# get messages from the Field classes
foreach my $type (@field_types) {
    my $class = "HTML::FormHandler::Field::$type";
    my $messages = eval '$HTML::FormHandler::Field::' . $type . '::class_messages';
    next unless keys %$messages;
    push @$all_messages, { $type => $messages };
}

$Data::Dumper::Terse = 1;
my $output = Dumper($all_messages);

my $outfile = getcwd() . '/util/messages';
open( my $fh, '>', $outfile ) or die "Unable to open $outfile";
print $fh $output;
close $fh;

# you can pull in the arrayref of hashrefs that's written out
my $recovered = eval $output;

sub wanted {
    my $type = $_;
    return if $type eq '.';
    $type =~ s/\.pm$//;
    return if $type eq 'Result';
    my $field_class = "HTML::FormHandler::Field::$type";
    if( try_load_class( $field_class ) ) {
        push @field_types, $type;
    }
    else {
        print "did not load $type\n";
    }

}
