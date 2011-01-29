use strict;
use warnings;
use Test::More;

# This is an example of the different ways to change an attribute of a field.
# It uses the 'id' field for demonstration purposes - most of these methods
# can also be used against other attributes.

{
    package Test::IDRole;
    use Moose::Role;

    sub build_id {
        my $self = shift;
        return  "meth_role." . $self->html_name;
    }

}

# can't use a simple method role in field_traits because
# it's applied against the base field class which contains
# the 'build_id' method. a method in a role won't override
# a method in a class itself. It *will* override a method in
# a superclass, so this kind of role can be applied against
# the field subclasses
# a method modifier can be used to override a field class
# method
{
    package Test::IDRoleMM;
    use Moose::Role;

    around 'build_id' => sub {
        my $orig = shift;
        my $self = shift;
        return "mm_role." . $self->html_name;
    };
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';


    # function with lexical variable
    my $name = 'test_form';
    my $create_id = sub {
        my $field_name = shift;
        return "$name.$field_name";
    };

    sub BUILD {
        my $self = shift;
        $self->field('tue')->id('my_build.tue');
    }

    has "+name" => ( default => $name );
    has '+field_traits' => ( default => sub {['Test::IDRoleMM']} );
    has_field 'foo' => ( id => 'form.foo' );
    has_field 'bar' => ( id => &my_id );
    has_field 'dux' => ( traits => ['Test::IDRole'] );
    has_field 'pax';
    has_field 'mon' => ( id => &$create_id('mon') );
    has_field 'tue';

    sub my_id { 'my_form.bar' }

}

#my $form = Test::Form->new( field_traits => ['Test::IDRole'] );
my $form = Test::Form->new;
ok( $form, 'form built' );
is( $form->field('foo')->id, 'form.foo', 'id attribute works' );
is( $form->field('bar')->id, 'my_form.bar', 'id function works' );
is( $form->field('dux')->id, 'meth_role.dux', 'build_id role works' );
is( $form->field('pax')->id, 'mm_role.pax', 'role with meth modifier around build_id works' );
is( $form->field('mon')->id, 'test_form.mon', 'build_id function with var' );
is( $form->field('tue')->id, 'my_build.tue', 'set id in BUILD' );

done_testing;
