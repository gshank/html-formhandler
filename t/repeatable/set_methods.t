use strict;
use warnings;
use Test::More;

{
    package MyApp::Form::Rep;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'testform' );
    has_field 'foo';
    has_field 'my_array' => ( type => 'Repeatable' );
    has_field 'my_array.one';
    has_field 'my_array.two' => ( type => 'Select' );
    has_field 'my_array.three';

    sub validate_my_array_one {
        my ( $self, $field ) = @_;
        if( $field->value eq 'wrong' ) {
            $field->add_error( 'wrong value' );
        }
    }
    sub options_my_array_two {
       return (
           1   => 'one',
           2   => 'two',
           3   => 'three',
       );
    }
    sub default_my_array_three { 'default_three' }
}

my $form = MyApp::Form::Rep->new;
ok( $form );
$form->process;
my $options = $form->field('my_array.0.two')->options;
my $expected_options = [
   {  'label' => 'one', 'value' => 1 },
   {  'label' => 'two', 'value' => 2 },
   {  'label' => 'three', 'value' => 3 },
];
is_deeply( $options, $expected_options, 'options built ok' );
my $default = $form->field('my_array.0.three')->value;
is( $default, 'default_three', 'default built ok' );
my $params = {
   'foo' => 'fff',
   'my_array.0.one' => 'wrong',
   'my_array.0.three' => 'default_three',
   'my_array.0.two' => 'tutu',
};
$form->process( params => $params );
ok( $form->has_errors, 'form has errors' );

done_testing;
