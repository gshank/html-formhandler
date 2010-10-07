use strict;
use warnings;
use Test::More;

{
    package Test::Dates;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar' => ( type => 'Hidden' );
    has_field 'foo_date' => ( type => 'Date' );

}

my $form = Test::Dates->new;
my $field_updates = {
        foo_date => { format => '%m/%e/%Y', date_start => '10-01-01'  },
        bar => { default => 'formabc' },
};
my $fif = {};
$form->process( update_field_list => $field_updates, params => $fif );
is( $form->field('foo_date')->date_start, '10-01-01', 'field updated' );
is( $form->field('foo_date')->format, '%m/%e/%Y', 'field updated' );
is( $form->field('bar')->value, 'formabc', 'hidden field has custom value' );
$fif = $form->fif;
$fif->{foo} = 'testing';
$fif->{foo_date} = '10-06-22';
$form->process( update_field_list => $field_updates, params => $fif );
is( $form->field('foo_date')->date_start, '10-01-01', 'field updated' );
is( $form->field('foo_date')->format, '%m/%e/%Y', 'field updated' );
is( $form->field('bar')->value, 'formabc', 'hidden field has custom value' );
is( $form->field('foo')->value, 'testing', 'correct value for foo' );


{
    package Test::Field::Updates;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has 'form_id' => ( isa => 'Str', is => 'rw' );

    has_field 'foo';
    has_field 'bar';
    has_field 'blah' => ( type => 'Hidden' );

    sub update_fields {
        my $self = shift;
        $self->field('foo')->temp( 'foo_temp' );
        $self->field('bar')->default( 'foo_value' );
        $self->field('blah')->default( $self->form_id );
    }
}

$form = Test::Field::Updates->new;
$fif = {};
$form->process( form_id => 'page1form', params => $fif );
is( $form->field('foo')->temp, 'foo_temp', 'foo field updated' );
is( $form->field('bar')->value, 'foo_value', 'foo value updated from default' );
is( $form->field('blah')->value, 'page1form', 'right value for hidden field' );
$fif = $form->fif;
$fif->{foo} = 'fooforall';
$fif->{bar} = 'barbiedoll';
$form->process( form_id => 'page1form', params => $fif );
is( $form->field('foo')->temp, 'foo_temp', 'foo field updated' );
is( $form->field('bar')->value, 'barbiedoll', 'foo value updated from default' );
is( $form->field('blah')->value, 'page1form', 'right value for hidden field' );
is( $form->field('foo')->value, 'fooforall', 'right value for foo' );

done_testing;

