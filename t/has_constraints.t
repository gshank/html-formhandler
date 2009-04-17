use Test::More tests => 3;


{
   package Test::Form;

   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_constraint 'contains_aaa' => ( check => qr/aaa/, message => 'Must contain aaa' );
   has_constraint 'greater_than_10' => ( check => sub { if( $_[0] =~ /(\d+)/ ){ return $1 > 10 } },
      message => 'must be greater than 10' );

   has_field 'no_aaa' => ( constraints => [ 'contains_aaa' ] );
   has_field 'correct' => ( constraints => [ ' contains_aaa' ] );
   has_field 'callback_error' => ( constraints => [ 'greater_than_10' ] );
   has_field 'callback_pass' => ( constraints => [ 'greater_than_10' ] );
}

my $form = Test::Form->new;
ok( $form, 'get form with constraint' );

ok( $form->_has_named_constraints, 'named constraints were created' );
ok( $form->_get_named_constraint('greater_than_10'), 'get named constraint' );
