use strict;
use warnings;
use Test::More;
use Test::Exception;

# tests the inflate_default_method
{
    package Test::Deflate;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => (
        default => 'inflate me!',
        inflate_default_method =>
            sub {
                my ( $self, $value ) = @_;

                if ( $value eq 'inflate me!' ) {
                    return 'inflated value';
                } else {
                    return 'unexpected value';
                }
            }
    );

}

my $form = Test::Deflate->new;
ok( $form, 'form builds' );
$form->process( params => {} );
is( $form->field('foo')->value, 'inflated value', 'inflate default values with inflate_default' );
$form->process( params => { foo => 'foo_from_params' } );
is( $form->field('foo')->value, 'foo_from_params', 'value out is from params' );

done_testing;
