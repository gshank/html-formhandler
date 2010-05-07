use strict;
use warnings;
use Test::More;

{
    package My::Default;
    use Moose::Role;

    sub build_default_over_obj {
        return 'From Method';
    }
}

{
   package My::Other::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'testform_' );
   has_field 'optname' => ( temp => 'First' );
   has_field 'reqname' => ( required => 1, default_over_obj => 'From Attribute' ); 
   has_field 'altname' => ( traits => ['My::Default'] );
   has_field 'somename';

   sub default_somename {
      my $self = shift;
      return 'SN from meth';
   }
}

my $init_object = { reqname => 'Starting Perl', optname => 'Over Again', altname => 'test' };
my $form = My::Other::Form->new;
ok( $form, 'get form' );
my $params = { reqname => 'Sweet', optname => 'Charity', somename => 'Exists' };

$form->process( init_object => $init_object, params => $params ); 
ok( $form->validated, 'form with init_obj & params validated' );
is( $form->field('reqname')->init_value, 'From Attribute', 'correct init_value');
is(  $form->field('optname')->init_value, 'Over Again', 'correct init_value no meth');
is( $form->field('altname')->init_value, 'From Method', 'correct init_value from trait');
is( $form->field('somename')->init_value, 'SN from meth', 'correct for init_obj undef');
is( $form->field('somename')->value, 'Exists', 'correct value for init_obj undef');

$form = My::Other::Form->new( init_object => $init_object );
is( $form->field('somename')->init_value, 'SN from meth', 'correct init_value new w init_obj');

done_testing;
