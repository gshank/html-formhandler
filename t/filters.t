use Test::More;
use lib 't/lib';

use DateTime;

BEGIN
{
   plan tests => 4;
}

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'sprintf_filter' => (
      type    => 'Text',
      filters => [ sub{ sprintf '<%.1g>', $_[0] } ]
   );
   has_field 'date_time_error' => (
      type    => 'Text',
      filters => [ sub{ DateTime->new( $_[0] ) } ],
   );
   has_field 'date_time' => ( 
      type => 'Compound',
      filters => [ sub{ DateTime->new( $_[0] ) } ],
   );
   has_field 'date_time.year' => ( type => 'Text', );
   has_field 'date_time.month' => ( type => 'Text', );
   has_field 'date_time.day' => ( type => 'Text', );

}


my $form = My::Form->new();
ok( $form, 'get form' );

my $params = $form->validate(
   {
      sprintf_filter   => '100',
      date_time_error  => 'aaa',
      'date_time.year' => 2009,
      'date_time.month' => 4,
      'date_time.day' => 16,
   }
);

is( $form->field('sprintf_filter')->value, '<1e+02>', 'sprintf filter' );
ok( $form->field('date_time_error')->has_errors,      'DateTime error catched' );
is( ref $form->field('date_time')->value, DateTime,   'DateTime object created' );

