use strict;
use warnings;

use Test::More;
use lib 't/lib';

use DateTime;
use Scalar::Util qw(blessed);

$ENV{LANG} = 'en_us'; # in case user has LANG set

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   use Moose::Util::TypeConstraints;

   subtype 'MyStr'
       => as 'Str'
       => where { /^a/ };

   subtype 'MyInt'
       => as 'Int';

   coerce 'MyInt'
       => from 'MyStr'
       => via { return $1 if /(\d+)/ };

   type 'MyDateTime'
       => message { 'This is not a correct date' }
       => where { blessed $_[0] && $_[0]->isa( 'DateTime' ) };
   coerce 'MyDateTime'
       => from 'HashRef'
       => via { DateTime->new( $_ ) };

   has_field 'coderef_transform'=> (
      apply => [{ transform => \&my_transform }]
   );
   has_field 'sprintf_filter' => (
      apply => [ { transform => sub{ sprintf '<%.1g>', $_[0] } } ]
   );
   has_field 'regex_trim' => (
       trim => { transform => sub { 
               my $string = shift;
               $string =~ s/^\s+//;
               $string =~ s/\s+$//;
               return $string;
        }}
   ); 
   has_field 'date_time_error' => (
      apply => [ { transform => sub{ DateTime->new( $_[0] ) },
                   message => 'Not a valid DateTime' } ],
   );
   has_field 'date_time' => (
      type => 'Compound',
      apply => [ { transform => sub{ DateTime->new( $_[0] ) } } ],
   );
   has_field 'date_time.year' => ( type => 'Text', );
   has_field 'date_time.month' => ( type => 'Text', );
   has_field 'date_time.day' => ( type => 'Text', );

   has_field 'coerce_error' => (
      apply => [ 'MyInt' ]
   );
   has_field 'coerce_pass' => (
      apply => [ 'MyInt' ]
   );

   has_field 'date_coercion_pass' => (
      type => 'Compound',
      apply => [ 'MyDateTime' ],
   );
   has_field 'date_coercion_pass.year' => ( type => 'Text', );
   has_field 'date_coercion_pass.month' => ( type => 'Text', );
   has_field 'date_coercion_pass.day' => ( type => 'Text', );

   has_field 'date_coercion_error' => (
      type => 'Compound',
      apply => [ 'MyDateTime' ],
   );
   has_field 'date_coercion_error.year' => ( type => 'Text', );
   has_field 'date_coercion_error.month' => ( type => 'Text', );
   has_field 'date_coercion_error.day' => ( type => 'Text', );

   has_field 'date_time_fif' => (
      type => 'Compound',
      apply => [ { transform => sub{ DateTime->new( $_[0] ) } } ],
      inflation => sub { { year => 1000, month => 1, day => 1 } },
      fif_from_value => 1,
   );
   has_field 'date_time_fif.year' => ( fif_from_value => 1 );
   has_field 'date_time_fif.month';
   has_field 'date_time_fif.day' => ( fif_from_value => 1 );

   sub my_transform {
      $_[0] =~ s/testing/IT WORKED/g;
      return $_[0];
   }
}


my $form = My::Form->new();
ok( $form, 'get form' );

my $params = {
      sprintf_filter   => '100',
      regex_trim => "  xxxy  \n",
      coderef_transform => 'testing',
      date_time_error  => 'aaa',
      'date_time.year' => 2009,
      'date_time.month' => 4,
      'date_time.day' => 16,
      coerce_error => 'b10',
      coerce_pass  => 'a10',
      'date_coercion_pass.year' => 2009,
      'date_coercion_pass.month' => 4,
      'date_coercion_pass.day' => 16,
      'date_coercion_error.year' => 2009,
      'date_coercion_error.month' => 20,
      'date_coercion_error.day' => 16,
      'date_time_fif.year' => 2009,
      'date_time_fif.month' => 4,
      'date_time_fif.day' => 16,
};
$form->process($params);

like( $form->field('sprintf_filter')->value, qr/<1e\+0+2>/, 'sprintf filter' );
is( $form->field('regex_trim')->value, 'xxxy', 'regex trim' );
is( $form->field('coderef_transform')->value, 'IT WORKED', 'coderef transform' );
ok( $form->field('date_time_error')->has_errors,      'DateTime error catched' );
is( $form->field('date_time_error')->errors->[0], 'Not a valid DateTime', 'error message');
is( ref $form->field('date_time')->value, 'DateTime',   'DateTime object created' );
ok( $form->field('coerce_error')->has_errors,     'no suitable coercion - error' );
is( $form->field('coerce_pass')->value, 10, 'coercion filter' );
is( ref $form->field('date_coercion_pass')->value, 'DateTime',   'values coerced to DateTime object' );
ok( $form->field('date_coercion_error')->has_errors,     'DateTime coercion error' );
my $message = $form->field('date_coercion_error')->errors->[0];
is( $message, 'This is not a correct date', 'Error message for coercion' );

is( $form->field( 'date_time_fif.year' )->fif, 2009, 'fif for year' );
$params->{'date_time_fif.year'} = 2009;
$params->{'date_time_fif.day'} = 16;
is_deeply( $form->fif, $params, 'fif is correct' );
is( $form->value->{date_time_fif}->year, 2009, 'right value' );

done_testing;
