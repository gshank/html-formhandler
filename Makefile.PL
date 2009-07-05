use strict;
use warnings;
use inc::Module::Install 0.89;

BEGIN {
    if ($Module::Install::AUTHOR) { # Not strictly needed, but reminds idiots like
                                    # me what M::I extensions I need ;)
        require Module::Install::AuthorRequires;
    }
}

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
requires 'HTML::Entities';
requires 'MooseX::Getopt' => '0.16';
requires 'MooseX::Types' => 0;
requires 'MooseX::Types::Common' => 0;
requires 'aliased';

# things the tests need
test_requires 'Test::More'      => '0.77';

author_requires 'DBIx::Class';
author_requires 'DBIx::Class::ResultSet::RecursiveUpdate' => '0.010';
author_requires 'DateTime::Format::MySQL';
author_requires 'DateTime::Format::W3CDTF' => 0;
author_requires 'DateTime::Format::SQLite';

eval { require DBIx::Class };
unless ( $@ )
{
   requires 'DBIx::Class::ResultSet::RecursiveUpdate' => '0.010';
}

tests();
author_tests('t/dbic');
author_tests('t/xt');

install_script 'form_generator.pl';
auto_install();

WriteAll();

# Strip requirement from META.yml generated
if ($Module::Install::AUTHOR) {
    Meta->{values}{requires} = [ grep {
        $_ ne 'DBIx::Class::ResultSet::RecursiveUpdate'
    } @{Meta->{values}{requires}} ];
    Meta->write;
}

