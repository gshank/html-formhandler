use strict;
use warnings;
use Test::More;

{
    package Test::Dates;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'foo_date' => ( type => 'Date' );

}

my $form = Test::Dates->new;
my $params = { foo => 'testing', foo_date => '10-06-22' };
$form->process( update_field_list => { foo_date => { format => '%m/%e/%Y', date_start => '10-01-01' } }, params => $params );
is( $form->field('foo_date')->date_start, '10-01-01', 'field updated' );
is( $form->field('foo_date')->format, '%m/%e/%Y', 'field updated' );

{
    package Test::Field::Updates;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar';

    sub update_fields {
        my $self = shift;
        $self->field('foo')->temp( 'foo_temp' );
        $self->field('bar')->default( 'foo_value' );
    }
}

$form = Test::Field::Updates->new;
$form->process;
is( $form->field('foo')->temp, 'foo_temp', 'foo field updated' );
is( $form->field('bar')->value, 'foo_value', 'foo value updated from default' );

done_testing;

