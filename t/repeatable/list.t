use strict;
use warnings;
use Test::More;

use_ok('HTML::FormHandler::Field::Repeatable');

{
   package List::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'tags' => ( type => 'Repeatable' );
   has_field 'tags.contains';

   sub validate_tags_contains {
       my ( $self, $field ) = @_;
       if ( $field->value eq 'busybee' ) {
           $field->add_error('That tag is not allowed');
       }
   }
}

my $form = List::Form->new;

ok( $form, 'form created' );

my $params = {
   tags => ['linux', 'algorithms', 'loops'],
};
$form->process($params);

ok( $form->validated, 'form validated' );

is( $form->field('tags')->field('0')->value, 'linux', 'get correct value' );

my $fif = {
   'tags.0' => 'linux',
   'tags.1' => 'algorithms',
   'tags.2' => 'loops',
};
is_deeply( $form->fif, $fif, 'fif is correct' );

is_deeply( $form->values, $params, 'values are correct' );

$params = { tags => ['busybee', 'sillysally', 'missymim'] };
$form->process($params);
ok( $form->has_errors, 'form has errors' );

done_testing;
