use strict;
use warnings;
use Test::More 0.88;
use Devel::Cycle;
{
    package FormHandlerMemLeak;

    use HTML::FormHandler::Moose;
    extends qw/HTML::FormHandler/;

    has_field test => ( type => "Text");

    sub default_test {
        return "test";
    }
    sub validate_test {
        return 1;
    }

    __PACKAGE__->meta->make_immutable;
}

my $i = FormHandlerMemLeak->new;
find_cycle($i, sub { fail("Cycle found") });
ok $i;
done_testing;


