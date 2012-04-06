use strict;
use warnings;
use Test::More;

# Test using the 'include' attribute for building fields
# to skip the build overhead for unused fields.
{
    package Test::Form::Fields;
    use HTML::FormHandler::Moose::Role;

    has_field 'foo';
    has_field 'bar';
    has_field 'ark';
    has_field 'cat';
    has_field 'dog';
    has_field 'ewe';
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'Test::Form::Fields';

    sub build_include { ['foo', 'ark', 'dog', 'ewe' ] }
}

my $form = Test::Form->new;
is( $form->num_fields, 4, 'right number of fields' );

done_testing;
