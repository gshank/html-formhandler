use strict;
use warnings;
use Test::More;
use Test::Exception;

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
is_deeply( $form->fif, { 'foo.one' => 1, 'foo.two' => 2, 'foo.three' => 3, bar => 'xxyyzz' },
    'fif is correct' );

my $fif =  { bar => 'aabbcc', 'foo.one' => 'x', 'foo.two' => 'xx', 'foo.three' => 'xxx' };
$form->process( params => $fif );
ok( $form->validated, 'form validated' );
is_deeply( $form->value, { bar => 'aabbcc', foo => 'one-x-two-xx-three-xxx' }, 'right value' );
is_deeply( $form->fif, $fif, 'right fif' );
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


{
    package Test::Deflate2;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'bullets' => ( type => 'Text',
        apply => [ { transform => \&string_to_array } ],
        deflation => \&array_to_string,
        deflate_to => 'fif',
    );
    sub array_to_string {
       my ( $value ) = @_;
       my $string = '';
       my $sep = '';
       for ( @$value ) {
           $string .= $sep . $_->{text};
           $sep = ';';
       }
       return $string;
    }
    sub string_to_array {
        my $value = shift;
        return [ map { { text => $_ } } split(/\s*;\s*/, $value) ];
    }
}

$init_object = { bullets => [{ text => 'one'}, { text => 'two' }, { text => 'three'}] };
$fif = { bullets => 'one;two;three' };
$form = Test::Deflate2->new;
ok( $form, 'form built');
$form->process( init_object => $init_object, params => {} );
is_deeply( $form->fif, $fif, 'right fif' );
is_deeply( $form->value, $init_object, 'right value' );

$form->process( params => $fif );
is_deeply( $form->fif, $fif, 'right fif' );
is_deeply( $form->value, $init_object, 'right value' );

{
    package Form::Field::Length;
    use Moose;
    extends 'HTML::FormHandler::Field::Text';

    sub deflate {
        my $self = shift;
        $self->value;
    }
}

{
    package Form::Recording;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'length' => (type => '+Form::Field::Length');
}

{

    package Entity::Recording;
    use Moose;
    has length => ( is => 'rw' );
}

my $entity = Entity::Recording->new;
ok( $entity, 'entity built' );
$form = Form::Recording->new(init_object => $entity);
ok( $form, 'form built' );
lives_ok( sub { $form->process({}); }, "no failure because of deflate accessing field's sub value" );

done_testing;
