use strict;
use warnings;
use Test::More;

{
    package Test::Deflate;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'bullets' => ( type => 'Text',
        inflate_method => \&string_to_array,
        deflate_method => \&array_to_string,
        deflate_to => 'fif',
    );
    sub array_to_string {
       my ( $self, $value ) = @_;
       my $string = '';
       my $sep = '';
       for ( @$value ) {
           $string .= $sep . $_->{text};
           $sep = ';';
       }
       return $string;
    }
    sub string_to_array {
        my ( $self, $value ) = @_;
        return [ map { { text => $_ } } split(/\s*;\s*/, $value) ];
    }
}

my $init_object = { bullets => [{ text => 'one'}, { text => 'two' }, { text => 'three'}] };
my $fif = { bullets => 'one;two;three' };
my $form = Test::Deflate->new;
ok( $form, 'form built');
$form->process( init_object => $init_object, params => {} );
is_deeply( $form->fif, $fif, 'right fif' );
is_deeply( $form->value, $init_object, 'right value' );

$form->process( params => $fif );
is_deeply( $form->fif, $fif, 'right fif' );
is_deeply( $form->value, $init_object, 'right value' );

done_testing;
