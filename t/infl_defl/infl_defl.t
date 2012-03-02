use strict;
use warnings;
use Test::More;

{
    # This form takes an array from the init_object and flattens it
    # into a string for displaying in a form;
    # When the string is submitted from the form, it's then
    # inflated into an array for validation and for returning
    # in the 'value' hashref.#
    {
        package Test::Deflate1;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'bullets' => ( type => 'Text',
            inflate_method => \&string_to_array,
            validate_method => \&check_bullets,
            deflate_method => \&array_to_string,
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
        sub check_bullets {
            my $self = shift;
            my $value = $self->value;
            unless( ref $value eq 'HASH' && scalar @$value == 3 ) {
                $self->add_error('bullets not valid');
            }
        }
        sub string_to_array {
            my ( $self, $value ) = @_;
            return [ map { { text => $_ } } split(/\s*;\s*/, $value) ];
        }
    }

    my $init_object = { bullets => [{ text => 'one'}, { text => 'two' }, { text => 'three'}] };
    my $fif = { bullets => 'one;two;three' };
    my $form = Test::Deflate1->new;
    ok( $form, 'form built');
    $form->process( init_object => $init_object, params => {} );
    is_deeply( $form->fif, $fif, 'right fif' );
    is_deeply( $form->value, $init_object, 'right value' );

    $form->process( params => $fif );
    is_deeply( $form->fif, $fif, 'right fif' );
    is_deeply( $form->value, $init_object, 'right value' );
}

done_testing;
