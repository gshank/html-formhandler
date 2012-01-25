use strict;
use warnings;
use Test::More;

{
    package Test::Composed;
    use Moose;
    with 'HTML::FormHandler::Traits';

    has 'test' => ( is => 'rw' );
    has 'foo' => ( is => 'rw' );
}

{
    package Test::Another;
    use Moose;
    with 'HTML::FormHandler::Traits';
    has 'another_test' => ( is => 'rw' );
}

{
    package Test::Trait::One;
    use Moose::Role;

    has 'test_one' => ( is => 'rw' );
}

{
    package Test::Trait::Two;
    use Moose::Role;

    has 'test_two' => ( is => 'rw' );

}

my $class = Test::Composed->with_traits( 'Test::Trait::One', 'Test::Trait::Two' );
is( $class, 'Test::Composed::1', 'got class' );

my $obj1 = $class->new( test_one => 1, test_two => 2 );
ok( $obj1, 'constructed an instance' );
is( $obj1->test_one, 1, 'right value' );

$class = Test::Composed->with_traits( 'Test::Trait::Two' );
is( $class, 'Test::Composed::2', 'got a class' );

my $obj2 = $class->new( test_two => 3 );
ok( $obj2, 'constructed an instance' );
is( $obj2->test_two, 3, 'right value' );

$class = Test::Another->with_traits( 'Test::Trait::One' );
is( $class, 'Test::Another::3', 'right class name' );
my $obj3 = $class->new( 'another_test' => 1 );
is( $obj3->another_test, 1, 'instance ok' );

my $obj4 = Test::Another->new_with_traits( traits => ['Test::Trait::Two'], test_two => 'foo' );
is( $obj4->test_two, 'foo', 'instantiated ok' );
is( $obj4->meta->name, 'Test::Another::4', 'named ok' );


done_testing;
