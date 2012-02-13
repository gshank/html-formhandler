use strict;
use warnings;
use Test::More;
use Data::Dumper;

# tests that hashref attributes are not shared between instances
# of a form
{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( tags => { one => 1, two => 2, three => 3 } );
    has_field 'bar';

}
my $form1 = Test::Form->new;
my $form2 = Test::Form->new;
my $form3 = Test::Form->new;

$form2->field('foo')->delete_tag('two');

# no cloning necessary for field_list
is( scalar keys %{$form1->field('foo')->tags}, 3, 'right number of tags keys' );
is( scalar keys %{$form2->field('foo')->tags}, 2, 'right number of tags keys' );
is( scalar keys %{$form1->field('foo')->tags}, 3, 'right number of tags keys' );

my $form4 = new_form();
my $form5 = new_form();
my $form6 = new_form();
$form5->field('foo')->delete_tag('two');

is( scalar keys %{$form4->field('foo')->tags}, 3, 'right number of tags keys' );
is( scalar keys %{$form5->field('foo')->tags}, 2, 'right number of tags keys' );
is( scalar keys %{$form6->field('foo')->tags}, 3, 'right number of tags keys' );

sub new_form {
    my $form = HTML::FormHandler->new(
        field_list => [
            { name => 'foo', type => 'Text', tags => { one => 1, two => 2, three => 3 } },
            { name => 'bar' },
            { name => 'save', type => 'Submit' },
        ],
    );
    return $form;
}

done_testing;
