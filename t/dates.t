use strict;
use warnings;
use Test::More;


BEGIN {
   eval "use DateTime::Format::Strptime";
   plan skip_all => 'DateTime::Format::Strptime required' if $@;
}

#
# DateMDY
#
my $class = 'HTML::FormHandler::Field::DateMDY';
use_ok($class);
my $field = $class->new( name => 'test_field', );
ok( defined $field, 'new() called for DateMDY' );
$field->input('10/02/2009');
$field->validate_field;
ok( $field->validated, 'No errors 1' );
ok( $field->value->isa('DateTime'), 'isa DateTime' );
$field->clear_data;
$field->input('14/40/09');
$field->validate_field;
ok( $field->has_errors, 'Has error 1' );
is( $field->fif, '14/40/09', 'Correct value' );
$field->clear_data;
$field->input('02/29/2009');
$field->validate_field;
ok( $field->has_errors, 'Has error 2' );
is( $field->fif, '02/29/2009', 'isa DateTime' );
$field->clear_data;
$field->input('12/31/2008');
$field->validate_field;
ok( $field->validated, 'No errors 2' );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif ok');
$field->clear_data;
$field->input('07/07/09');
ok( $field->validated, 'No errors 3' );
$field->clear_data;
$field->value( DateTime->new( year => 2008, month => 12, day => 31 ) );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif from value ok');


#
# Date
#
$class = 'HTML::FormHandler::Field::Date';
use_ok($class);
$field = $class->new( name => 'test_field', format => "mm/dd/yy" );
ok( defined $field, 'new() called for DateMDY' );
$field->input('02/10/2009');
$field->validate_field;
ok( $field->validated, 'No errors 1' );
ok( $field->value->isa('DateTime'), 'isa DateTime' );
$field->clear_data;
$field->date_start('2009-10-01');
$field->input('08/01/2009');
$field->validate_field;
ok( $field->has_errors, 'Date is too early' );
is( $field->fif, '08/01/2009', 'Correct value' );
$field->clear_date_start;
$field->clear_data;
$field->date_end('2010-01-01');
$field->input('02/01/2010');
$field->validate_field;
ok( $field->has_errors, 'date is too late');
$field->input('02/29/2009');
$field->validate_field;
ok( $field->has_errors, 'Not a valid date' );
is( $field->fif, '02/29/2009', 'isa DateTime' );
$field->clear_data;
$field->input('12/31/2008');
$field->validate_field;
ok( $field->validated, 'No errors 2' );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif ok');
$field->clear_data;
$field->value( DateTime->new( year => 2008, month => 12, day => 31 ) );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif from value ok');
$field->format("%d-%m-%Y");
$field->input('07-07-09');
ok( $field->validated, 'No errors 3' );
$field->clear_data;
$field->value( DateTime->new( year => 2008, month => 12, day => 31 ) );
is( $field->fif, $field->value->strftime("%d-%m-%Y", 'fif ok' ), 'fif from value ok');


{
   package Test::Date;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::Simple';

   has_field 'end_date' => ( type => 'Date' );
}

my $form = Test::Date->new;
ok( $form, 'form with date created' );
ok( $form->render_field('end_date'), 'date field renders' );

done_testing;
