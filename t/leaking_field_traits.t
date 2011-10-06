use strict;
use warnings;
use Test::More;
use Test::Exception;

use lib ('t/lib');
{
    package My::Field::CustomAttr;
    use Moose::Role;

    has 'custom_attr' => ( is => 'rw' );
}

{
    package My::Form::WithCustomAttr;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+field_traits' => ( default => sub { ['My::Field::CustomAttr'] } );
    has_field 'foo' => ( custom_attr => 1234 );
}

my $form = My::Form::WithCustomAttr->new;

# Check that the custom attribute exists (this should work)
lives_ok { $form->field('foo')->custom_attr } 'custom attr exists';

# Ensure that the correct value got set (my 'fixes' broke this)
is($form->field('foo')->custom_attr, 1234, 'custom attr value is correct');


{
    package My::Form::WithoutCustomAttr;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'bar';
}

# Check that the previous custom attribute hasn't leaked into this field
$form = My::Form::WithoutCustomAttr->new;
throws_ok { $form->field('bar')->custom_attr }
    qr/Can't locate object method "custom_attr"/,
    'custom attr should not exist';

done_testing;
