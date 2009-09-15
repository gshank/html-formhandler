use strict;
use warnings;
use inc::Module::Install 0.89;

BEGIN {
    if ($Module::Install::AUTHOR) { # Not strictly needed, but reminds idiots like
                                    # me what M::I extensions I need ;)
        require Module::Install::AuthorTests;
    }
}

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
requires 'HTML::Entities';
requires 'MooseX::Getopt' => '0.16';
requires 'MooseX::Types' => '0.20';
requires 'MooseX::Types::Common';
requires 'namespace::autoclean';
requires 'aliased';
requires 'File::Spec';
requires 'Class::Load' => '0.05';
requires 'namespace::autoclean' => '0.09';

# things the tests need
test_requires 'Test::More'      => '0.88';
test_requires 'Test::Differences';
test_requires 'Test::Exception';

tests();
author_tests('t/xt');

auto_install();

WriteAll();

