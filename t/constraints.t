use Test::More;
use lib 't/lib';

BEGIN
{
   plan tests => 11;
}

{

   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   use Moose::Util::TypeConstraints;

   subtype 'Natural'
       => as 'Int'
       => where { $_ > 0 };
 
   subtype 'NaturalLessThanTen'
       => as 'Natural'
       => where { $_ < 10 }
       => message { "This number ($_) is not less than ten!" };
 
   coerce 'Num'
       => from 'Str'
         => via { 0+$_ };
 
   enum 'RGBColors' => qw(red green blue);
 
   no Moose::Util::TypeConstraints;
   
   has_field 'empty_field' => (
      actions => [ { check => qr/aaa/, message => 'Must contain aaa' } ],
   );
   has_field 'regex_error' => (
      actions => [ { check => qr/aaa/, message => 'Must contain aaa' } ],
   );
   has_field 'regex_correct' => (
      actions => [ { check => qr/aaa/, message => 'Must contain aaa' } ],
   );
   has_field 'set_error' => (
      actions => [
         {
            check   => [ 'aaa', 'bbb' ],
            message => 'Must be "aaa" or "bbb"'
         }
      ]
   );
   has_field 'set_correct' => (
      actions => [
         {
            check   => [ 'aaa', 'bbb' ],
            message => 'Must be "aaa" or "bbb"'
         }
      ]
   );
   has_field 'callback_error' => (
      actions => [
         {
             check => sub { if ( $_[0] =~ /(\d+)/ ) { return $1 > 10 } },
             message => 'Must contain number greater than 10',
         }
      ]
   );
   has_field 'callback_pass' => (
      actions => [
         {
             check => sub { if ( $_[0] =~ /(\d+)/ ) { return $1 > 10 } },
             message => 'Must contain number greater than 10',
         }
      ]
   );
   has_field 'less_than_ten_error' => (
      actions => [ 'NaturalLessThanTen' ]
   );
   has_field 'less_than_ten_pass' => (
      actions => [ 'NaturalLessThanTen' ]
   );
}

my $form = My::Form->new();
ok( $form, 'get form' );

my $params = $form->validate(
   {
      empty_field              => '',
      regex_error              => 'bbb',
      regex_correct            => 'bbb aaa',
      set_error                => 'ccc',
      set_correct              => 'aaa',
      callback_error           => 'asdf 2',
      callback_pass            => 'asdf 20 asd',
      less_than_ten_error => 10,
      less_than_ten_pass  => 9,
   }
);
# ok( $form->field('empty_field')->has_errors, 'empty does not pass required constraint' );
ok( $form->field('regex_error')->has_errors,    'regexp constraint - error' );
ok( !$form->field('regex_correct')->has_errors, 'regexp constraint - pass' );
ok( $form->field('regex_correct')->has_value,   'constraints passed - has_value is true' );
ok( !$form->field('set_correct')->has_errors,              'set correct' );
ok( $form->field('set_error')->has_errors,                 'set error' );
ok( $form->field('callback_error')->has_errors,            'callback constraint - error' );
ok( !$form->field('callback_pass')->has_errors,            'callback constraint - pass' );
ok( $form->field('less_than_ten_error')->has_errors,     'type constraint - error' );
my ( $message ) = $form->field('less_than_ten_error')->errors;
is( $message, "This number (10) is not less than ten!", 'type constraint - error message' );
ok( !$form->field('less_than_ten_pass')->has_errors,     'type constraint - pass' );
#warn Dumper( $form ); use Data::Dumper;
