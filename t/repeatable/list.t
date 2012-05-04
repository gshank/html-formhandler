use strict;
use warnings;
use Test::More;

use_ok('HTML::FormHandler::Field::Repeatable');

{
   package List::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'name';
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

# check for single empty repeatable
$form->process;
my $fif = {
   'name' => '',
   'tags.0' => '',
};
is_deeply( $form->fif, $fif, 'fif ok' );
is_deeply( $form->value, {}, 'value ok' );

# empty arrayref for repeatable
$fif->{name} = 'mary';
$form->process( $fif );
is_deeply( $form->value, { name => 'mary', tags => [] },
   'value is ok' );

my $params = {
   name => 'joe',
   tags => ['linux', 'algorithms', 'loops'],
};
$form->process($params);

ok( $form->validated, 'form validated' );

is( $form->field('tags')->field('0')->value, 'linux', 'get correct value' );

$fif = {
   'name' => 'joe',
   'tags.0' => 'linux',
   'tags.1' => 'algorithms',
   'tags.2' => 'loops',
};
is_deeply( $form->fif, $fif, 'fif is correct' );

is_deeply( $form->values, $params, 'values are correct' );

$params = { name => 'sally', tags => ['busybee', 'sillysally', 'missymim'] };
$form->process($params);
ok( $form->has_errors, 'form has errors' );

done_testing;
