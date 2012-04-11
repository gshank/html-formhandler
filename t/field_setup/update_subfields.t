use strict;
use warnings;
use Test::More;

# tests that 'by_flag' works for contains
# Test 'by_type' flag
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

# test using update_subfields with base class

{
    package Test::Form::Base;
    use Moose;
    extends 'HTML::FormHandler';

    sub build_update_subfields {
        return { all => { tags => { no_errors => 1 } } };
    }
}
{
    package Test::Form::Special;
    use HTML::FormHandler::Moose;
    extends 'Test::Form::Base';
    use HTML::FormHandler::Merge ('merge');

    sub build_update_subfields {
        my $self = shift;
        my $new = { all => { tags => { wrapper_tag => 'p' } } };
        return merge( $new, $self->next::method(@_) );
    }
    has_field 'foo';
    has_field 'bar';
}
$form = Test::Form::Special->new;
ok( $form );
my $expected = { no_errors => 1, wrapper_tag => 'p' };
is_deeply( $form->field('foo')->tags, $expected, 'got expected tags' );

done_testing;
