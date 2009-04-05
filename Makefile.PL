use strict;
use warnings;
use inc::Module::Install;

name 'HTML-FormHandler';
all_from 'lib/HTML/FormHandler.pm';
license 'perl';

# prereqs
requires 'Carp';
requires 'Moose'              => '0.59';
requires 'MooseX::AttributeHelpers' => '0.14';
requires 'UNIVERSAL::require' => '0';
requires 'Locale::Maketext'   => '1.09';
requires 'DateTime';
requires 'DBIx::Class';
requires 'HTML::Entities';
requires 'MooseX::Getopt' => '0.16';

recommends 'Catalyst';
recommends 'Catalyst::Component::InstancePerContext';
recommends 'Template';
recommends 'Test::WWW::Mechanize::Catalyst' => '0.50';

# things the tests need
test_requires 'Test::More'      => '0.77';
test_requires 'DateTime::Format::MySQL';

tests_recursive();

install_script 'form_generator.pl'; 
auto_install();

WriteAll();

