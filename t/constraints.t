use strict;
use warnings;
use Test::More;
use lib 't/lib';

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
      apply => [ { check => qr/aaa/, message => 'Must contain aaa' } ],
   );
   has_field 'regex_error' => (
      apply => [ { check => qr/xyz/ } ],
   );
   has_field 'regex_correct' => (
      apply => [ { check => qr/aaa/, message => 'Must contain aaa' } ],
   );
   has_field 'message_sub' => (
      apply => [
         {
            check   => [ 'abc' ],
            message => \&err_message
         }
      ]
   );
   sub err_message {
       my ($value, $field ) = @_;
       return $field->name . ': Must be "abc"';
   }

   has_field 'set_error' => (
      apply => [
         {
            check   => [ 'abc', 'bbb' ],
            message => 'Must be "aaa" or "bbb"'
         }
      ]
   );
   has_field 'set_correct' => (
      apply => [
         {
            check   => [ 'aaa', 'bbb' ],
            message => 'Must be "aaa" or "bbb"'
         }
      ]
   );
   has_field 'callback_error' => (
      apply => [
         {
             check => sub { if ( $_[0] =~ /(\d+)/ ) { return $1 > 10 } },
             message => 'Must contain number greater than 10',
         }
      ]
   );
   has_field 'callback_pass' => (
      apply => [
         {
             check => \&check_callback_pass,
             message => 'Must contain number greater than 10',
         }
      ]
   );
   sub check_callback_pass {
       my ( $value, $field ) = @_;
       if( $value =~ /(\d+)/ ) {
           return $1 > 10;
       }
   }
   has_field 'less_than_ten_error' => (
      apply => [ 'NaturalLessThanTen' ]
   );
   has_field 'less_than_ten_pass' => (
      apply => [ 'NaturalLessThanTen' ]
   );
}

my $form = My::Form->new();
ok( $form, 'get form' );

my $params = {
      empty_field              => '',
      regex_error              => 'bbb',
      regex_correct            => 'bbb aaa',
      set_error                => 'ccc',
      set_correct              => 'aaa',
      callback_error           => 'asdf 2',
      callback_pass            => 'asdf 20 asd',
      less_than_ten_error      => 10,
      less_than_ten_pass       => 9,
      message_sub              => 'xyz',
};
$form->process($params);
# ok( $form->field('empty_field')->has_errors, 'empty does not pass required constraint' );
ok( $form->field('regex_error')->has_errors,    'regexp constraint - error' );
ok( !$form->field('regex_correct')->has_errors, 'regexp constraint - pass' );
ok( $form->field('regex_correct')->has_value,   'constraints passed - has_value is true' );
is( $form->field('message_sub')->errors->[0], 'message_sub: Must be "abc"',    'error from message sub' );
ok( !$form->field('set_correct')->has_errors,              'set correct' );
ok( $form->field('set_error')->has_errors,                 'set error' );
ok( $form->field('callback_error')->has_errors,            'callback constraint - error' );
ok( !$form->field('callback_pass')->has_errors,            'callback constraint - pass' );
ok( $form->field('less_than_ten_error')->has_errors,     'type constraint - error' );
my $message = $form->field('less_than_ten_error')->errors->[0];
is( $message, "This number (10) is not less than ten!", 'type constraint - error message' );
ok( !$form->field('less_than_ten_pass')->has_errors,     'type constraint - pass' );
#warn Dumper( $form ); use Data::Dumper;
is_deeply( $form->fif, $params, 'fif is correct');

done_testing;
