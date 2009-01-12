package MyTest;
use strict;
use warnings;
use base 'Exporter';
use Test::More;

@MyTest::EXPORT = @Test::More::EXPORT;


sub import {
    my ( $self, %options ) = @_;

    __PACKAGE__->export_to_level( 1, __PACKAGE__ );


    if ( my $mods = $options{recommended} ) {
        for (  ref $mods ? @$mods : $mods ) {
            unless ( eval "require $_" ) {
                if ( $ENV{TEST_ALL_MODULES} ) {
                    plan tests => 1;
                    require_ok( $_ );
                    return;
                }

                plan skip_all => "Missing recommended module [$_]";
                return;
            }
        }
    }

    plan tests => $options{tests} if $options{tests};
}


1;
