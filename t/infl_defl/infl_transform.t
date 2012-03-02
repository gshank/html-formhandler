use strict;
use warnings;
use Test::More;
use Test::Exception;

# check that transform acts correctly as inflation, and
# sub deflation works ok.

{
    package Test::Deflate2;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'bullets' => ( type => 'Text',
        apply => [ { transform => \&string_to_array } ],
        deflation => \&array_to_string,
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

my $init_object = { bullets => [{ text => 'one'}, { text => 'two' }, { text => 'three'}] };
my $fif = { bullets => 'one;two;three' };
my $form = Test::Deflate2->new;
ok( $form, 'form built');
$form->process( init_object => $init_object, params => {} );
is_deeply( $form->fif, $fif, 'right fif' );
is_deeply( $form->value, $init_object, 'right value' );

$form->process( params => $fif );
is_deeply( $form->fif, $fif, 'right fif' );
is_deeply( $form->value, $init_object, 'right value' );

done_testing;
