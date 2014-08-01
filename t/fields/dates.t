use strict;
use warnings;
use Test::More;


use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = 'en_en';

#
# DateMDY
#
my $class = 'HTML::FormHandler::Field::DateMDY';
use_ok($class);
my $field = $class->new( name => 'test_field', );
$field->build_result;
ok( defined $field, 'new() called for DateMDY' );
$field->_set_input('10/02/2009');
$field->validate_field;
ok( $field->validated, 'No errors 1' );
ok( $field->value->isa('DateTime'), 'isa DateTime' );
$field->reset_result;
$field->_set_input('14/40/09');
$field->validate_field;
ok( $field->has_errors, 'Has error 1' );
is( $field->fif, '14/40/09', 'Correct value' );
$field->reset_result;
$field->_set_input('02/29/2009');
$field->validate_field;
ok( $field->has_errors, 'Has error 2' );
is( $field->fif, '02/29/2009', 'isa DateTime' );
$field->reset_result;
$field->_set_input('12/31/2008');
$field->validate_field;
ok( $field->validated, 'No errors 2' );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif ok');
$field->reset_result;
$field->_set_input('07/07/09');
ok( $field->validated, 'No errors 3' );
$field->reset_result;
$field->_deflate_and_set_value( DateTime->new( year => 2008, month => 12, day => 31 ) );
is( $field->fif, '12/31/2008', 'fif from value ok');


#
# Date
#
$class = 'HTML::FormHandler::Field::Date';
use_ok($class);
$field = $class->new( name => 'test_field', format => "mm/dd/yy" );
$field->build_result;
ok( defined $field, 'new() called for DateMDY' );
$field->_set_input('02/10/2009');
$field->validate_field;
ok( $field->validated, 'No errors 1' );
ok( $field->value->isa('DateTime'), 'isa DateTime' );
$field->reset_result;
$field->date_start('2009-10-01');
$field->_set_input('08/01/2009');
$field->validate_field;
ok( $field->has_errors, 'Date is too early' );
is( $field->fif, '08/01/2009', 'Correct value' );

$field->clear_date_start;
$field->reset_result;
$field->date_end('2010-01-01');
$field->_set_input('02/01/2010');
$field->validate_field;
ok( $field->has_errors, 'date is too late');
$field->_set_input('02/29/2009');
$field->validate_field;
ok( $field->has_errors, 'Not a valid date' );
is( $field->fif, '02/29/2009', 'isa DateTime' );

$field->reset_result;
$field->_set_input('12/31/2008');
$field->validate_field;
ok( $field->validated, 'No errors 2' );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif ok');

$field->reset_result;
$field->_deflate_and_set_value( DateTime->new( year => 2008, month => 12, day => 31 ) );
is( $field->fif, '12/31/2008', 'fif from deflated value ok');
$field->format("%d-%m-%Y");
$field->_set_input('07-07-09');
$field->validate_field;
ok( $field->validated, 'No errors 3' );
is( $field->fif, '07-07-09', 'fif ok');

$field->reset_result;
$field->format("%m/%d/%Y");
$field->_set_input('12/31/2008');
$field->time_zone('America/Los_Angeles');
$field->validate_field;
ok( $field->validated, 'No errors 3a');
is( $field->value->time_zone->name, 'America/Los_Angeles' );



{
   package Test::Date;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::Simple';

   has_field 'start_date' => ( type => 'Date' );
   has_field 'end_date' => ( type => 'Date', required => 1 );
   has_field 'another_date' => ( type => 'Date' );
}

{
    package My::Date;
    use base 'DateTime';
}

my $form = Test::Date->new;
ok( $form, 'form with date created' );
ok( $form->render_field('end_date'), 'date field renders' );
ok( !$form->process( params => { end_date => '' } ), "Didn't validate Test::Date with empty string for end_date" );

my $adate = My::Date->new( year => '2014', month => '05', day => '20' );
$form = Test::Date->new( item => { end_date => '1999-01-01', start_date => '', another_date => $adate } );
ok( !$form->process( params => { } ), "Didn't validate Test::Date with empty params" );
is( $form->field('another_date')->fif, '2014-05-20', 'date fif is correct' );
ok( $form->process( params => { end_date => '1999-12-31', another_date => '2014-05-20' } ), "validated ok" );

#
# DateTime
#
$class = 'HTML::FormHandler::Field::DateTime';
use_ok($class);
#$field = $class->new( name => 'test_field', format => "mm/dd/yy" );
$field = $class->new( name => 'test_field', field_list => [ year => 'Integer',
    month => 'Integer', day => 'Integer' ] );
ok( defined $field, 'new() called for DateTime' );
$field->build_result;
$field->_set_input({ month => 2, day => 10, year => 2009 });
$field->test_validate_field;
ok( $field->validated, 'No errors 1' );
ok( $field->value && $field->value->isa('DateTime'), 'isa DateTime' );
is( $field->value->ymd, '2009-02-10', 'correct DateTime' );

$field = $class->new( name => 'test_field', field_list => [ year => 'Integer',
    month => { type => 'Integer', range_start => 9, range_end => 12 }, day => 'Integer' ] );
ok( $field, 'field compiles and builds' );

$field->reset_result;
my $date_hash = { month => 5, day => 10, year => 2009 };
$field->_set_input($date_hash);
$field->test_validate_field;
ok( $field->has_errors, 'Date is wrong month' );
is( $field->fif, $date_hash, 'Correct value' );

$field->reset_result;
$date_hash = { month => 10, day => 32, year => 2009 };
$field->_set_input($date_hash);
$field->test_validate_field;
ok( $field->has_errors, 'Date is wrong month' );
like( $field->errors->[0], qr/Not a valid/, 'DateTime error message' );
is( $field->fif, $date_hash, 'Correct value' );

{
    package Test::DateTime;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'my_date' => ( type => 'DateTime' );
    has_field 'my_date.month';
    has_field 'my_date.year';
    has_field 'my_date.day';
}
$form = Test::DateTime->new;
my $dt = DateTime->new( year => '2010', month => '02', day => '22' );
$form->process( init_object => { foo => 'abc', my_date => $dt } );
is_deeply( $form->field('my_date')->fif, { year => '2010', month => '2', day => '22' },
    'right fif from obj with date' );
my $fif = $form->fif;
is( $fif->{'my_date.day'}, '22', 'right fif day');
$fif->{'my_date.day'} = '15';
$form->process( params => $fif );
ok( $form->validated, 'form validated' );
is( $form->field('my_date')->value->mdy, '02-15-2010', 'right value for my_date' );

done_testing;
