use strict;
use warnings;

use lib './t';
use MyTest
    tests   => 2,
    recommended => [qw/ DateTime /];



    my $class = 'HTML::FormHandler::Field::DateTime';

    my $name = $1 if $class =~ /::([^:]+)$/;

    use_ok( $class );

    my $field = $class->new(
        name    => 'test_field',
        type    => $name,
        form    => undef,
    );

    ok( defined $field,  'new() called' );


