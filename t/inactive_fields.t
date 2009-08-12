use strict;
use warnings;
use Test::More;

{
   package Test::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'bar';
   has_field 'foo' => ( inactive => 1 );
   has_field 'foo_checkbox' => ( type => 'Checkbox', inactive => 1 );
}

my $form = Test::Form->new;
ok( $form, 'form builds' );

is( $form->num_fields, 3, 'right number of fields' );
is( scalar @{$form->sorted_fields}, 1, 'right number of sorted fields' );

$form->field('foo')->clear_inactive;
is( scalar @{$form->sorted_fields}, 2, 'right number of sorted fields after clear_inactive' );

my $fif = {
   bar => 'bar_test',
   foo => 'foo_test',
};
$form->process($fif);
ok( $form->validated, 'form validated' );
is_deeply( $form->fif, $fif, 'fif is correct' );
is_deeply( $form->value, $fif, 'value is correct' );


done_testing;
