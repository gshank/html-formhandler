use Test::More;
use lib 't/lib';

BEGIN {
   plan tests => 12;
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
       constraints => [ 'required', { check => qr/aaa/, message => 'Must contain aaa' } ] 
   );
   has_field 'correct' => ( 
       type => 'Text', 
       constraints => [ 'required', { check => qr/aaa/, message => 'Must contain aaa' } ] 
   );
   has_field 'callback_error' => ( 
       type => 'Text', 
       constraints => [ { check => sub{ if( $_[0] =~ /(\d+)/ ){ return $1 > 10 } } , message => 'Must contain number greater than 10' } ] 
   );
   has_field 'callback_pass' => ( 
       type => 'Text', 
       constraints => [ { check => sub{ if( $_[0] =~ /(\d+)/ ){ return $1 > 10 } } , message => 'Must contain number greater than 10' } ] 
   );
   has_field 'range_error' => ( 
       type => 'Text', 
       constraints => [ { named => 'range', range_start => 1, range_end => 2, } ] 
   );
   has_field 'range_low_error' => ( 
       type => 'Text', 
       constraints => [ { named => 'range', range_start => 1, } ] 
   );
   has_field 'range_high_error' => ( 
       type => 'Text', 
       constraints => [ { named => 'range', range_end => 2, } ] 
   );
   has_field 'range_correct' => ( 
       type => 'Text', 
       constraints => [ { named => 'range', range_start => 1, range_end => 2, } ] 
   );
   has_field 'size_error' => ( 
       type => 'Text', 
       constraints => [ { named => 'size', minlength => 1, maxlength => 2, } ] 
   );
   has_field 'size_correct' => ( 
       type => 'Text', 
       constraints => [ { named => 'size', minlength => 1, maxlength => 2, } ] 
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
    range_error => 3,
    range_low_error => 0,
    range_high_error => 3,
    range_correct => 2,
    size_error => '123',
    size_correct => '12',
});
# ok( $form->field('empty_field')->has_errors, 'empty does not pass required constraint' );
ok( $form->field('no_aaa')->has_errors, 'regexp constraint - error' );
ok( ! $form->field('correct')->has_errors, 'regexp constraint - pass' );
ok( $form->field('correct')->has_value, 'constraints passed - has_value is true' );
ok( $form->field('callback_error')->has_errors, 'callback constraint - error' );
ok( ! $form->field('callback_pass')->has_errors, 'callback constraint - pass' );
ok( $form->field('range_error')->has_errors, 'range error' );
ok( $form->field('range_high_error')->has_errors, 'range high error' );
ok( $form->field('range_low_error')->has_errors, 'range low error' );
ok( !$form->field('range_correct')->has_errors, 'range correct' );
ok( $form->field('size_error')->has_errors, 'size error' );
ok( !$form->field('size_correct')->has_errors, 'size correct' ) or warn $form->field('size_correct')->errors;

#warn Dumper( $form ); use Data::Dumper;
