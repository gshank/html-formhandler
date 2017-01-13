#!/usr/bin/env perl

#============================================================
# util/copy-iso639-1-to-3.pl
#
# This is a utility for copy I18N files and change package
# names from ISO639-1 to ISO639-3.
#
# Author: 2014, Tomas Valousek, PetaMem s.r.o., tv@petamem.com
#
#============================================================

use strict;
use warnings;

use Cwd;
use File::Find;

my $iso639_data = iso639_data();
my $directory = getcwd() . "/lib/HTML/FormHandler/I18N";
my @i18n_files;
find(\&wanted, $directory);

for my $iso639_1 (@i18n_files) {
    my $iso639_3              = $iso639_data->{$iso639_1} // die "missing iso639-3 code for $iso639_1";
    my $original_package_name = "HTML::FormHandler::I18N::$iso639_1";
    my $new_package_name      = "HTML::FormHandler::I18N::$iso639_3";

    my $package_content = read_file("$directory/$iso639_1.pm");
    $package_content =~ s{$original_package_name}{$new_package_name}xms;
    write_file("$directory/$iso639_3.pm", $package_content);
}

sub wanted {
    my $name = $_;
    $name =~ s/\.pm$//;
    push @i18n_files, $name
        if $name =~ m{ \w{5} }xms;
}

sub read_file {
    my $filename = shift;
 
    open my $in, '<:encoding(UTF-8)', $filename or die "Could not open '$filename' for reading $!";
    local $/ = undef;
    my $all = <$in>;
    close $in;
 
    return $all;
}
 
sub write_file {
    my $filename = shift;
    my $content  = shift;
 
    open my $out, '>:encoding(UTF-8)', $filename or die "Could not open '$filename' for writing $!";;
    print $out $content;
    close $out;
 
    return;
}

sub iso639_data {
    return {
        pt_br => 'por',
        ar_kw => 'ara',
        de_de => 'deu',
        it_it => 'ita',
        hu_hu => 'hun',
        sv_se => 'swe',
        ru_ru => 'rus',
        bg_bg => 'bul',
        cs_cz => 'ces',
        ja_jp => 'jpn',
        en_us => 'eng',
        ua_ua => 'ukr',
        tr_tr => 'tur',
    };
}
