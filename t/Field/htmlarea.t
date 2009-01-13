use strict;
use warnings;

use lib './t';
use MyTest
    tests   => 3,
    recommended => [qw/ HTML::Tidy File::Temp /];



my $class = 'HTML::FormHandler::Field::HtmlArea';
my $name = $1 if $class =~ /::([^:]+)$/;

# Mosty to test for bad nesting

my $good_html = <<'';
    <p>This is nice
    and clean
    </p>
    <p><b>and bold</b></p>

my $bad_html = <<'';
    <p>This is nice
    and clean but not well formatted
    </p>
    <p><b>and bold without ending tag</p>



    use_ok( $class );
    my $field = $class->new(
        name    => 'test_field',
        type    => $name,
        form    => undef,
    );

    ok( defined $field,  'new() called' );


    $field->input(  $bad_html );
    $field->validate_field;
    ok( $field->has_errors, 'Test for failure' );


