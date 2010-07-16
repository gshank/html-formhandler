use Test::More tests => 2;

use_ok( 'HTML::FormHandler::Model::CDBI' );

{
   package Test::CDBI;
   use Moose;
   extends 'HTML::FormHandler::Model::CDBI';

}

my $form = Test::CDBI->new;
ok( $form, 'get form from CDBI model' );
