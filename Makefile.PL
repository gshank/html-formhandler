use strict;
use warnings;
use inc::Module::Install;

name 'HTML-FormHandler';
all_from 'lib/HTML/FormHandler.pm';
license 'perl';

# prereqs
requires 'perl'             => '5.008';
requires 'Scalar::Util'     => '1.19';
requires 'Carp';

# things the tests need
build_requires 'Test::More'      => '0.77';

tests_recursive();

WriteAll();

