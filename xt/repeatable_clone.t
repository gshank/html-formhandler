use strict;
use warnings;
use Test::More;

# tests that we have a valid form reference after
#  merging attributes for a repeatable instance and a
# form package with a 'clone' method
{
    package MyApp::Form::Rep;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    use Clone ('clone');

    has '+name' => ( default => 'testform' );
    has_field 'foo';
    has_field 'my_array' => ( type => 'Repeatable' );
    has_field 'my_array.one';
    has_field 'my_array.two' => ( type => 'Select' );
    has_field 'my_array.three';

    sub build_update_subfields {
        { all => { wrap_label_method => \&wrap_label } }
    }

    sub wrap_label {
        my $self = shift; # field
        my $label = $self->label;
        return qq{<a href="/some/link">$label</a>};
    }

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
is( $form->field('my_array.0')->has_form, 1, 'has_form is true' );
ok( $form->field('my_array.0')->form, 'actually has form object' );
ok( $form == $form->field('my_array.0')->form, 'correct form object' );

done_testing;
