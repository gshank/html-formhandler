use Test::More;
use lib 't/lib';

BEGIN {
   plan tests => 6;
}

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'empty_field' => ( 
       type => 'Text', 
       constraints => [ 'required' ] 
   );
   has_field 'no_aaa' => ( 
       type => 'Text', 
       constraints => [ 'required', { predicate => qr/aaa/, message => 'Must contain aaa' } ] 
   );
   has_field 'correct' => ( 
       type => 'Text', 
       constraints => [ 'required', { predicate => qr/aaa/, message => 'Must contain aaa' } ] 
   );
   has_field 'callback_error' => ( 
       type => 'Text', 
       constraints => [ { predicate => sub{ if( $_[0] =~ /(\d+)/ ){ return $1 > 10 } } , message => 'Must contain number greater than 10' } ] 
   );
   has_field 'callback_pass' => ( 
       type => 'Text', 
       constraints => [ { predicate => sub{ if( $_[0] =~ /(\d+)/ ){ return $1 > 10 } } , message => 'Must contain number greater than 10' } ] 
   );
}

my $form = My::Form->new();
ok( $form, 'get form');

my $params = $form->validate( {
    empty_field => '',
    no_aaa => 'bbb',
    correct => 'bbb aaa',
    callback_error => 'asdf 2',
    callback_pass  => 'asdf 20 asd',
});
# ok( $form->field('empty_field')->has_errors, 'empty does not pass required constraint' );
ok( $form->field('no_aaa')->has_errors, 'regexp constraint - error' );
ok( ! $form->field('correct')->has_errors, 'regexp constraint - pass' );
ok( $form->field('correct')->has_value, 'constraints passed - has_value is true' );
ok( $form->field('callback_error')->has_errors, 'callback constraint - error' );
ok( ! $form->field('callback_pass')->has_errors, 'callback constraint - pass' );

#warn Dumper( $form ); use Data::Dumper;
