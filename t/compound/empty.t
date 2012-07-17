use strict;
use warnings;
use Test::More;

# tests behavior for an empty compound field, where the compund field value
# is undef
{
    {
        package MyApp::Test::Compound;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'comp_foo' => ( type => 'Compound', default => { one => 1, two => 2, three => 3 } );
        has_field 'comp_foo.one';
        has_field 'comp_foo.two';
        has_field 'comp_foo.three';
        has_field 'bar';
    }

    my $form = MyApp::Test::Compound->new;
    ok( $form );
    my $params = {
        'comp_foo.one' => '',
        'comp_foo.two' => '',
        'comp_foo.three' => '',
        'bar' => 'my_bar',
    };
    $form->process( params => $params );
    my $value = $form->value;
    my $exp_value = {
        comp_foo => undef,
        bar => 'my_bar',
    };
    is_deeply( $value, $exp_value, 'got expected value' );
}

# tests behavior for an empty compound field with 'not_nullable', where the
# compund field contains empty values
{
    {
        package MyApp::Test::Compound;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'comp_foo' => ( type => 'Compound', not_nullable => 1 );
        has_field 'comp_foo.one';
        has_field 'comp_foo.two';
        has_field 'comp_foo.three';
        has_field 'bar';
    }

    my $form = MyApp::Test::Compound->new;
    ok( $form );
    my $params = {
        'comp_foo.one' => '',
        'comp_foo.two' => '',
        'comp_foo.three' => '',
        'bar' => 'my_bar',
    };
    $form->process( params => $params );
    my $value = $form->value;
    my $exp_value = {
        comp_foo => {
            one => undef,
            two => undef,
            three => undef,
        },
        bar => 'my_bar',
    };
    is_deeply( $value, $exp_value, 'got expected value' );
}


done_testing;
