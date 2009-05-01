use strict;
use warnings;

use Test::More tests => 3;

use_ok( 'HTML::FormHandler::Types' );

{
   package My::TypeForm;
   use HTML::FormHandler::Moose;
   use HTML::FormHandler::Types;
   extends 'HTML::FormHandler';

   has_field 'pos_int' => ( apply => [ 'PosInteger' ] );
   has_field 'my_pw' => ( type => 'Password', apply => [ 'Password' ] );
   has_field 'my_nesstr' => ( apply => [ 'NonEmptyStr' ] );
   has_field 'my_sstr' => ( apply => [ 'SimpleStr' ] );

}

my $form = My::TypeForm->new;
ok( $form, 'get form with imported types' );
my $params = {
   pos_int => 4,
   my_pw => 'abc',
   my_nesstr => 'some string',
   my_sstr => '',
};
$form->validate( $params );
ok( $form->has_errors, 'errors from validation');

