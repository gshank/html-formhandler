use strict;
use warnings;
use Test::More;

{
    package Test::Field;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has_field 'one';
    has_field 'two';
    has_field 'three';

    has '+deflation' => ( default => sub { 
        sub { 
            my %hash = split(/-/, $_[0]);
            return \%hash;
        } 
    });
    apply ( [ { transform  => sub {
                my $value = shift;
                my $string = 'one-' . $value->{one};
                $string .= '-two-' . $value->{two};
                $string .= '-three-' . $value->{three};
                return $string; 
           } 
       } ]
    );
}
{
    package Test::Deflate;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( type => '+Test::Field' );
    has_field 'bar';
}

my $form = Test::Deflate->new;
ok( $form, 'form builds' );
my $init_object = { foo => 'one-1-two-2-three-3', bar => 'xxyyzz' };
$form->process( init_object => $init_object, params => {} );
is_deeply( $form->value, { foo => { one => 1, two => 2, three => 3 },
        bar => 'xxyyzz' }, 'value is correct?' );
$form->process( params => { bar => 'aabbcc', 'foo.one' => 'x', 'foo.two' => 'xx', 'foo.three' => 'xxx' } );
ok( $form->validated, 'form validated' );
is_deeply( $form->value, { bar => 'aabbcc', foo => 'one-x-two-xx-three-xxx' }, 'right value' );
is( $form->field('foo.one')->fif, 'x', 'correct fif' );
is( $form->field('foo')->value, 'one-x-two-xx-three-xxx', 'right value for foo field' );

{
    package Test::Deflate;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => (
        default => 'deflate me!',
        deflation => sub {
            my ( $value ) = @_;

            if ( $value eq 'deflate me!' ) {
                return 'deflated value';
            } else {
                return 'unexpected value';
            }
        }
    );
    
}

$form = Test::Deflate->new;
ok( $form, 'form builds' );

is( $form->field('foo')->value, 'deflated value', 'default values should be deflated too' );


done_testing;
