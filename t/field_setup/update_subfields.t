use strict;
use warnings;
use Test::More;

# tests that 'by_flag' works for contains
{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_update_subfields {{
        by_flag => { contains => { wrapper_class => ['rep_elem'] } },
        by_type => { 'Select' => { wrapper_class => ['sel_wrapper'] },
                     'BoolSelect' => { element_class => ['sel_elem'] },
        },
    }}
    has_field 'records' => ( type => 'Repeatable' );
    has_field 'records.one';
    has_field 'records.two';
    has_field 'foo' => ( type => 'Select', options => [
        { value => 1, label => 'One' }, { value => 2, label => 'Two' }] );
    has_field 'bar' => ( type => 'BoolSelect' );

}

my $form = Test::Form->new;
$form->process;
is_deeply( $form->field('records.0')->wrapper_class, ['rep_elem'], 'contains has correct class by flag' );
is_deeply( $form->field('foo')->wrapper_class, ['sel_wrapper'], 'correct class by type' );
is_deeply( $form->field('bar')->element_class, ['sel_elem'], 'correct class by type' );


done_testing;
