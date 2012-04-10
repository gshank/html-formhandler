use strict;
use warnings;
use Test::More;

# tests that 'by_flag' works for contains
{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_update_subfields { { by_flag => { contains => { wrapper_class => ['rep_elem'] } } } }
    has_field 'records' => ( type => 'Repeatable' );
    has_field 'records.one';
    has_field 'records.two';

}

my $form = Test::Form->new;
$form->process;
is_deeply( $form->field('records.0')->wrapper_class, ['rep_elem'], 'contains has correct class' );


done_testing;
