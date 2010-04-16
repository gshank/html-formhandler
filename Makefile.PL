use strict;
use warnings;
use inc::Module::Install 0.91;

# Not strictly needed, but reminds idiots like
# me what M::I extensions I need ;)
use Module::Install::AuthorTests;

name 'HTML-FormHandler';
author 'Gerda Shank';
all_from 'lib/HTML/FormHandler.pm';
license 'perl';

repository 'http://github.com/gshank/html-formhandler/tree/master';

# prereqs
requires 'Carp';
requires 'Moose'              => '0.90';
requires 'Locale::Maketext'   => '1.09';
requires 'DateTime';
requires 'MooseX::Getopt' => '0.16';
requires 'MooseX::Types' => '0.20';
requires 'MooseX::Types::Common';
requires 'MooseX::Traits';
requires 'aliased';
requires 'File::Spec';
requires 'File::ShareDir';
requires 'Try::Tiny';
requires 'namespace::autoclean' => '0.09';

# things the tests need
test_requires 'Test::More'      => '0.88';
test_requires 'Test::Differences';
test_requires 'Test::Exception';

tests();
author_tests('t/xt');

install_share 'share';

auto_install();

WriteAll();

