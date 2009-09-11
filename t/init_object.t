use Test::More;
use lib 't/lib';


{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'testform_' );
   has_field 'optname' => ( temp => 'First' );
   has_field 'reqname' => ( required => 1 );
   has_field 'somename';
}


my $form = My::Form->new( init_object => {reqname => 'Starting Perl',
                                       optname => 'Over Again' } );
ok( $form, 'non-db form created OK');
is( $form->field('optname')->value, 'Over Again', 'get right value from form');
$form->process({});
ok( !$form->validated, 'form validated' );
is( $form->field('reqname')->fif, 'Starting Perl', 
                      'get right fif with init_object');

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'initform_' );
   has_field 'foo' => ( temp => 'First' );
   has_field 'bar';
   has_field 'baz';
   has '+init_object' => ( default => sub { { foo => 'initfoo' } } );
   sub init_value_bar { 'init_value_bar' }
   sub init_value_baz { 'init_value_baz' }
}

$form = My::Form->new;
ok( $form->field('foo')->value, 'initfoo' );
ok( $form->field('bar')->value, 'init_value_bar' );
ok( $form->field('baz')->value, 'init_value_baz' );

done_testing;
