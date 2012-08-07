use strict;
use warnings;
use Test::More;

# this tests that a multiple select with value from an init_object
# has the right value with both a hashref and a blessed object
{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( type => 'Select', multiple => 1 );
    sub options_foo {
        [
            1 => 'One',
            2 => 'Two',
            3 => 'Three',
            4 => 'Four',
        ]
    }
    has_field 'bar';
}

{
    package FooObject;
    use Moose;
    has 'foo' => (
        is => 'ro',
        isa => 'ArrayRef',
        traits => ['Array'],
        handles => {
            'has_foo' => 'count',
        }
    );
    has 'bar' => ( is => 'ro', isa => 'Str' );
}

my $form = MyApp::Form::Test->new;
ok( $form );

# try with hashref
my $init_obj = {
    foo => [1],
    bar => 'my_test',
};
$form->process( init_object => $init_obj );
is_deeply( $form->field('foo')->value, [1], 'right value for foo field with hashref init_obj' );

# try with object
my $foo = FooObject->new(
    foo => [1],
    bar => 'my_test',
);
$form->process( init_object => $foo );
is_deeply( $form->field('foo')->value, [1], 'right value for foo field with object init_obj' );

done_testing;
