use strict;
use warnings;
use lib './t';
use MyTest
    tests   => 7,
    recommended => [qw/ Email::Valid /];



my $class = 'HTML::FormHandler::Field::Email';
my $name = $1 if $class =~ /::([^:]+)$/;


    use_ok( $class );
    my $field = $class->new(
        name    => 'test_field',
        type    => $name,
    );

    ok( defined $field,  'new() called' );

    $field->input( 'foo@bar.com' );
    $field->process;
    ok( !$field->has_errors, 'Test for errors 1' );
    is( $field->value, 'foo@bar.com', 'value returned' );

    $field->input( 'foo@bar' );
    $field->process;
    ok( $field->has_errors, 'Test for errors 1' );
    is( $field->errors->[0], 'Email should be of the format someuser@example.com', 'Test error message' );

    $field->input( 'someuser@example.com' );
    $field->process;
    ok( !$field->has_errors, 'Test for errors 2 although probably should fail' );



