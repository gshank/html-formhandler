use strict;
use warnings;
use Test::More;

{
    package MyApp::Field::DuplicateText;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Text';

    apply [ {
        transform => sub {
            my $value = shift;
            # collapses down to a single entry if passed a list where all
            # values are identical
            return $value->[0] if
                defined $value
                and ref $value eq 'ARRAY'
                and not grep { $value->[0] ne $_ } @$value;
            return $value;
        },
    }];
}


# tests the TextCSV field
{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( type => '+MyApp::Field::DuplicateText' );
    has_field 'bar' => ( type => '+MyApp::Field::DuplicateText' );
}

my $form = MyApp::Form::Test->new;
ok( $form );
$form->process( params => { foo => '1', bar => ['2,2'] } );

TODO: {
local $TODO = 'this test broke with commit 0cae37c6';

ok($form->validated, 'field of list values validates')
    or diag 'got errors: ', explain [ $form->errors_by_name ];

}

done_testing;
