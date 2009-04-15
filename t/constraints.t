use Test::More;
use lib 't/lib';

BEGIN
{
   plan tests => 17;
}

{

   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'empty_field' => (
      type        => 'Text',
      constraints => ['required']
   );
   has_field 'regex_error' => (
      type        => 'Text',
      constraints => [ 'required', [ qr/aaa/ => 'Must contain aaa' ] ]
   );
   has_field 'regex_correct' => (
      type        => 'Text',
      constraints => [ 'required', [ qr/aaa/ => 'Must contain aaa' ] ]
   );
   has_field 'regex_hash_style_correct' => (
      type        => 'Text',
      constraints => [ 'required', { check => qr/aaa/, message => 'Must contain aaa' } ]
   );
   has_field 'set_error' => (
      type        => 'Text',
      constraints => [ [ [ 'aaa', 'bbb' ] => 'Must be "aaa" or "bbb"' ] ]
   );
   has_field 'set_hash_style_error' => (
      type        => 'Text',
      constraints => [
         {
            check   => [ 'aaa', 'bbb' ],
            message => 'Must be "aaa" or "bbb"'
         }
      ]
   );
   has_field 'set_hash_style_correct' => (
      type        => 'Text',
      constraints => [
         {
            check   => [ 'aaa', 'bbb' ],
            message => 'Must be "aaa" or "bbb"'
         }
      ]
   );
   has_field 'set_correct' => (
      type        => 'Text',
      constraints => [ [ [ 'aaa', 'bbb' ] => 'Must be "aaa" or "bbb"' ] ]
   );
   has_field 'callback_error' => (
      type        => 'Text',
      constraints => [
         [
            sub {
               if ( $_[0] =~ /(\d+)/ ) { return $1 > 10 }
               } => 'Must contain number greater than 10'
         ]
      ]
   );
   has_field 'callback_pass' => (
      type        => 'Text',
      constraints => [
         [
            sub {
               if ( $_[0] =~ /(\d+)/ ) { return $1 > 10 }
               } => 'Must contain number greater than 10'
         ]
      ]
   );
   has_field 'range_error' => (
      type        => 'Text',
      constraints => [ [ 'range', 1, 2, ] ]
   );
   has_field 'range_low_error' => (
      type        => 'Text',
      constraints => [ [ 'range', 1, ] ]
   );
   has_field 'range_high_error' => (
      type        => 'Text',
      constraints => [ [ 'range', undef, 2, ] ]
   );
   has_field 'range_correct' => (
      type        => 'Text',
      constraints => [ [ 'range', 1, 2, ] ]
   );
   has_field 'size_error' => (
      type        => 'Text',
      constraints => [ [ 'size', 1, 2, ] ]
   );
   has_field 'size_correct' => (
      type        => 'Text',
      constraints => [ [ 'size', 1, 2, ] ]
   );
}

my $form = My::Form->new();
ok( $form, 'get form' );

my $params = $form->validate(
   {
      empty_field              => '',
      regex_error              => 'bbb',
      regex_correct            => 'bbb aaa',
      regex_hash_style_correct => 'bbb aaa',
      set_error                => 'ccc',
      set_correct              => 'aaa',
      set_hash_style_error     => 'ccc',
      set_hash_style_correct   => 'aaa',
      callback_error           => 'asdf 2',
      callback_pass            => 'asdf 20 asd',
      range_error              => 3,
      range_low_error          => 0,
      range_high_error         => 3,
      range_correct            => 2,
      size_error               => '123',
      size_correct             => '12',
   }
);
# ok( $form->field('empty_field')->has_errors, 'empty does not pass required constraint' );
ok( $form->field('regex_error')->has_errors,    'regexp constraint - error' );
ok( !$form->field('regex_correct')->has_errors, 'regexp constraint - pass' );
ok( $form->field('regex_correct')->has_value,   'constraints passed - has_value is true' );
ok( !$form->field('regex_hash_style_correct')->has_errors, 'regexp constraint - pass' );
ok( !$form->field('set_correct')->has_errors,              'set correct' );
ok( $form->field('set_error')->has_errors,                 'set error' );
ok( !$form->field('set_hash_style_correct')->has_errors,   'set correct' );
ok( $form->field('set_hash_style_error')->has_errors,      'set error' );
ok( $form->field('callback_error')->has_errors,            'callback constraint - error' );
ok( !$form->field('callback_pass')->has_errors,            'callback constraint - pass' );
ok( $form->field('range_error')->has_errors,               'range error' );
ok( $form->field('range_high_error')->has_errors,          'range high error' );
ok( $form->field('range_low_error')->has_errors,           'range low error' );
ok( !$form->field('range_correct')->has_errors,            'range correct' );
ok( $form->field('size_error')->has_errors,                'size error' );
ok( !$form->field('size_correct')->has_errors,             'size correct' )
   or warn $form->field('size_correct')->errors;

#warn Dumper( $form ); use Data::Dumper;
