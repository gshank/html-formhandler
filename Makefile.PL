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

recommends 'DBIx::Class';
recommends 'Catalyst';
recommends 'Catalyst::Component::InstancePerContext';
recommends 'Template';
recommends 'Test::WWW::Mechanize::Catalyst';

# things the tests need
build_requires 'Test::More'      => '0.77';

tests_recursive();

auto_install();

WriteAll();

