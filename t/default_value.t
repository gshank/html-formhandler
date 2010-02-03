use strict;
use warnings;
use Test::More;
 
use_ok('HTML::FormHandler');
 
{
 
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
 
   has '+name' => ( default => 'testform' );
   has_field 'ten' => ( type => 'PosInteger', default => 10 );
   has_field 'zero' => ( type => 'PosInteger', default => 0 );

}
 
my $form = My::Form->new;
 
ok( $form->result, 'result exists' );
is( $form->field('ten')->fif, 10 );
is( $form->field('zero')->fif, 0 );

done_testing;
