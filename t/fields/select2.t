use strict;
use warnings;
use Test::More;

{
    package MyApp::Test;
    use Moose;
    with 'HTML::FormHandler::TraitFor::Types';

    has 'foo' => (
        is => 'rw',
        isa => 'HFH::SelectOptions',
        coerce => 1,
    );
}

my $obj = MyApp::Test->new( foo => [ 1 => 'One', 2 => 'Two', 3 => 'Three' ] );

is_deeply( $obj->foo,
    [ { value => 1, label => 'One' }, { value => 2, label => 'Two' }, { value => 3, label => 'Three' } ],
    'value of foo is correct' );


{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => (
        type => 'Select',
        options => [
            1 => 'One',
            2 => 'Two',
            3 => 'Three',
        ],
    );
    has_field 'bar';

}

my $form = MyApp::Form::Test->new;
ok( $form );

done_testing;
