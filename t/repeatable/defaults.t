use strict;
use warnings;
use Test::More;

# tests that a default method works for a repeatable

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

    sub default_my_array {
        my $self = shift;
        return (
            { one => 'abc1', two => 2, three => 'abc3' },
            { one => 'def1', two => 3, three => 'def3' },
            { one => 'ghi1', two => 1, three => 'ghi3' }
        );
    }
    sub options_my_array_two {
       return (
           1   => 'one',
           2   => 'two',
           3   => 'three',
       );
    }
    # this won't take effect; the 'my_array' default has precedence
    # would be used for 'num_extra'
    sub default_my_array_three { 'default_three' }
}

my $form = MyApp::Form::Rep->new;
ok( $form );
$form->process;
is( $form->field('my_array')->num_fields, 3, 'right number of fields' );
my $fif = $form->fif;
my $exp_fif = {
   'foo' => '',
   'my_array.0.one' => 'abc1',
   'my_array.0.three' => 'abc3',
   'my_array.0.two' => 2,
   'my_array.1.one' => 'def1',
   'my_array.1.three' => 'def3',
   'my_array.1.two' => 3,
   'my_array.2.one' => 'ghi1',
   'my_array.2.three' => 'ghi3',
   'my_array.2.two' => 1,
};
is_deeply( $fif, $exp_fif, 'fif is correct' );
$fif->{foo} = 'foo_submitted';
$form->process( params => $fif );
my $values = $form->values;
my $exp_values = {
    foo => 'foo_submitted',
    my_array => [
        { one => 'abc1', two => 2, three => 'abc3' },
        { one => 'def1', two => 3, three => 'def3' },
        { one => 'ghi1', two => 1, three => 'ghi3' }
    ]
};
is_deeply( $values, $exp_values, 'got expected values' );


done_testing;
