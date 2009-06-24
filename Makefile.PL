use inc::Module::Install 0.89;
use strict;
use warnings;

name 'HTML-FormHandler';
author 'Gerda Shank';
all_from 'lib/HTML/FormHandler.pm';
license 'perl';

repository 'http://github.com/gshank/html-formhandler/tree/master';

# prereqs
requires 'Carp';
requires 'Moose'              => '0.70';
requires 'MooseX::AttributeHelpers' => '0.14';
requires 'Locale::Maketext'   => '1.09';
requires 'DateTime';
requires 'DBIx::Class';
requires 'DBIx::Class::ResultSet::RecursiveUpdate' => '0.010';
requires 'HTML::Entities';
requires 'MooseX::Getopt' => '0.16';
requires 'MooseX::Types' => 0;
requires 'MooseX::Types::Common' => 0;
requires 'aliased';

recommends 'Catalyst';
recommends 'Catalyst::Component::InstancePerContext';
recommends 'Template';
recommends 'Test::WWW::Mechanize::Catalyst' => '0.50';

# things the tests need
test_requires 'Test::More'      => '0.77';
test_requires 'DateTime::Format::MySQL';
test_requires 'DateTime::Format::W3CDTF' => 0;
test_requires 'DateTime::Format::SQLite';

tests_recursive();

install_script 'form_generator.pl'; 
auto_install();

WriteAll();

