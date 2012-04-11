use strict;
use warnings;
use Test::More;

# Test using the 'include' attribute on a compound field
# to limit the fields that are built.
# alternative to active/inactive. Created for a situation
# in which there are a very large number of fields in a
# field/role and you don't want the overhead of building them
# and then setting them activie/inactive.
{
    package Test::FooField;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has_field 'foo';
    has_field 'bar';
    has_field 'box';
    has_field 'mix';
    has_field 'nix';

}

my $field = Test::FooField->new( name => 'muddly' );
ok( $field );

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'fiddly';
    has_field 'muddly' => ( type => '+Test::FooField', include => ['foo', 'mix', 'nix'] );
    # no subfields. kinda weird...
    has_field 'middly' => ( type => '+Test::FooField', include => [ 'empty' ] );
}

my $form = Test::Form->new;
ok( $form );
is( $form->field('muddly')->num_fields, 3, 'right number of fields' );
is( $form->field('middly')->num_fields, 0, 'right number of fields' );

done_testing;
