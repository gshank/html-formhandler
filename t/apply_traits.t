use strict;
use warnings;
use Test::More;
use Test::Exception;

use lib ('t/lib');

# Test applying a trait to the Field base class
{
    package My::Field::CustomAttr;
    use Moose::Role;

    has 'custom_attr' => ( is => 'rw' );
}

{
    package My::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
}

{
    my $form = My::Form->new;
    throws_ok { $form->field('foo')->custom_attr }
        qr/Can't locate object method "custom_attr"/,
        'custom attr should not exist';

    HTML::FormHandler::Field->apply_traits('My::Field::CustomAttr');

    lives_ok { $form->field('foo')->custom_attr(1234) }
        'custom attr should now exist';
    is( $form->field('foo')->custom_attr, 1234,
        'custom attr value as expected' );
}


# Test applying a trait to a Field sub-class
{
    package My::Field::CustomAttr2;
    use Moose::Role;

    has 'custom_attr2' => ( is => 'rw' );
}

{
    package My::Form2;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( type => 'Checkbox' );
    has_field 'bar' => ( type => 'Text'     );
    has_field 'baz' => ( type => 'Password' );
}

{
    my $form = My::Form2->new;
    for (qw/ foo bar baz /) {
        throws_ok { $form->field($_)->custom_attr2 }
            qr/Can't locate object method "custom_attr2"/,
            'custom attr should not exist';
    }

    # Apply the trait to the Text field. This should appear in the Text and
    # Password fields, but not the Checkbox.
    HTML::FormHandler::Field::Text->apply_traits('My::Field::CustomAttr2');

    throws_ok { $form->field('foo')->custom_attr2 }
        qr/Can't locate object method "custom_attr2"/,
        'custom attr should not exist'; # Checkbox is not a Text field

    lives_ok { $form->field('bar')->custom_attr2(2345) }
        'custom attr should now exist';
    is( $form->field('bar')->custom_attr2, 2345,
        'custom attr value as expected' );

    lives_ok { $form->field('baz')->custom_attr2(3456) }
        'custom attr should now exist';
    is( $form->field('baz')->custom_attr2, 3456,
        'custom attr value as expected' ); # Password is a Text field
}


done_testing;
