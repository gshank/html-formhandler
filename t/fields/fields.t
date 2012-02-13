use strict;
use warnings;

use Test::More;

use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = HTML::FormHandler::I18N->get_handle('en_en');

#
# Boolean
#
my $class = 'HTML::FormHandler::Field::Boolean';
use_ok($class);
my $field = $class->new( name => 'test', );
ok( defined $field, 'new() called' );
$field->_set_input(1);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'Test true == 1' );
$field->_set_input(0);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'Test true == 0' );
$field->_set_input('checked');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 1, 'Test true == 1' );
$field->_set_input('0');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 4' );
is( $field->value, 0, 'Test true == 0' );

# checkbox
$class = 'HTML::FormHandler::Field::Checkbox';
use_ok($class);
$field = $class->new( name => 'test', );
ok( defined $field, 'new() called' );
$field->_set_input(1);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'input 1 is 1' );
$field->_set_input(0);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'input 0 is 0' );
$field->_set_input('checked');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 'checked', 'value is "checked"' );
$field->_set_input(undef);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 4' );
is( $field->value, 0, 'input undef is 0' );
$field = $class->new(
   name     => 'test_field2',
   required => 1
);
$field->_set_input(0);
$field->validate_field;
ok( $field->has_errors, 'required field fails with 0' );


# email
$class = 'HTML::FormHandler::Field::Email';
use_ok($class);
$field = $class->new( name => 'test', );
ok( defined $field, 'new() called' );
my $address = 'test@example.com';
$field->_set_input( $address );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, $address, 'is value input string' );
my $Address = 'Test@example.com';
$field->_set_input( $Address );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, lc($Address), 'is value input string' );

# hidden

$class = 'HTML::FormHandler::Field::Hidden';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
my $string = 'Some text';
$field->_set_input( $string );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, $string, 'is value input string');
$field->_set_input( '' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, undef, 'is value input string');
$field->required(1);
$field->validate_field;
ok( $field->has_errors, 'Test for errors 3' );
$field->_set_input('hello');
$field->required(1);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 'hello', 'Check again' );
$field->maxlength( 3 );
$field->validate_field;
ok( $field->has_errors, 'Test for too long' );
$field->maxlength( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test for right length' );
$field->minlength( 10 );
$field->validate_field;
ok( $field->has_errors, 'Test not long enough' );
$field->minlength( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test just long enough' );
$field->minlength( 4 );
$field->validate_field;
ok( !$field->has_errors, 'Test plenty long enough' );

# integer

$class = 'HTML::FormHandler::Field::Integer';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->_set_input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'Test value == 1' );
$field->_set_input( 0 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'Test value == 0' );
$field->_set_input( 'checked' );
$field->validate_field;
ok( $field->has_errors, 'Test non integer' );
is( $field->errors->[0], 'Value must be an integer', 'correct error');
$field->_set_input( '+10' );
$field->validate_field;
ok( !$field->has_errors, 'Test positive' );
is( $field->value, 10, 'Test value == 10' );
$field->_set_input( '-10' );
$field->validate_field;
ok( !$field->has_errors, 'Test negative' );
is( $field->value, -10, 'Test value == -10' );
$field->_set_input( '-10.123' );
$field->validate_field;
ok( $field->has_errors, 'Test real number' );
$field->range_start( 10 );
$field->_set_input( 9 );
$field->validate_field;
ok( $field->has_errors, 'Test 9 < 10 fails' );
$field->_set_input( 100 );
$field->validate_field;
ok( !$field->has_errors, 'Test 100 > 10 passes ' );
$field->range_end( 20 );
$field->_set_input( 100 );
$field->validate_field;
ok( $field->has_errors, 'Test 10 <= 100 <= 20 fails' );
$field->range_end( 20 );
$field->_set_input( 15 );
$field->validate_field;
ok( !$field->has_errors, 'Test 10 <= 15 <= 20 passes' );
$field->_set_input( 10 );
$field->validate_field;
ok( !$field->has_errors, 'Test 10 <= 10 <= 20 passes' );
$field->_set_input( 20 );
$field->validate_field;
ok( !$field->has_errors, 'Test 10 <= 20 <= 20 passes' );
$field->_set_input( 21 );
$field->validate_field;
ok( $field->has_errors, 'Test 10 <= 21 <= 20 fails' );
$field->_set_input( 9 );
$field->validate_field;
ok( $field->has_errors, 'Test 10 <= 9 <= 20 fails' );


# intrange.t

$class = 'HTML::FormHandler::Field::IntRange';
use_ok( $class );
$field = $class->new(
    name    => 'test_field',
    range_start => 30,
    range_end   => 39,
);
ok( defined $field,  'new() called' );
$field->_set_input( 30 );
$field->validate_field;
ok( !$field->has_errors, '30 in range' );
$field->_set_input( 39 );
$field->validate_field;
ok( !$field->has_errors, '39 in range' );
$field->_set_input( 35 );
$field->validate_field;
ok( !$field->has_errors, '35 in range' );
$field->_set_input( 29 );
$field->validate_field;
ok( $field->has_errors, '29 out of range' );
$field->_set_input( 40 );
$field->validate_field;
ok( $field->has_errors, '40 out of range' );

# minute

$class = 'HTML::FormHandler::Field::Minute';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->_set_input( 0 );
$field->validate_field;
ok( !$field->has_errors, '0 in range' );
$field->_set_input( 59 );
$field->validate_field;
ok( !$field->has_errors, '59 in range' );
$field->_set_input( 12 );
$field->validate_field;
ok( !$field->has_errors, '12 in range' );
$field->_set_input( -1  );
$field->validate_field;
ok( $field->has_errors, '-1 out of range' );
$field->_set_input( 60 );
$field->validate_field;
ok( $field->has_errors, '60 out of range' );

# money

$class = 'HTML::FormHandler::Field::Money';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->_set_input( '   $123.45  ' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors "   $123.00  "' );
is( $field->value, 123.45, 'Test value == 123.45' );
$field->_set_input( '   $12x3.45  ' );
$field->validate_field;
ok( $field->has_errors, 'Test for errors "   $12x3.45  "' );
is( $field->errors->[0], 'Value cannot be converted to money', 'get error' );
$field->_set_input( 2345 );
$field->validate_field;
is( $field->value, '2345.00', 'transformation worked: 2345 => 2345.00' );


# monthday

$class = 'HTML::FormHandler::Field::MonthDay';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->_set_input( 1 );
$field->validate_field;
ok( !$field->has_errors, '1 in range' );
$field->_set_input( 31 );
$field->validate_field;
ok( !$field->has_errors, '31 in range' );
$field->_set_input( 12 );
$field->validate_field;
ok( !$field->has_errors, '12 in range' );
$field->_set_input( 0  );
$field->validate_field;
ok( $field->has_errors, '0 out of range' );
$field->_set_input( 32 );
$field->validate_field;
ok( $field->has_errors, '32 out of range' );

# monthname

$class = 'HTML::FormHandler::Field::MonthName';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
for ( 1 .. 12 ) {
    $field->_set_input( $_ );
    $field->validate_field;
    ok( !$field->has_errors, $_ . ' is valid' );
}
$field->_set_input( 0 );
$field->validate_field;
ok( $field->has_errors, '0 is not valid day of the week' );
$field->_set_input( 13 );
$field->validate_field;
ok( $field->has_errors, '13 is not valid day of the week' );

#month

$class = 'HTML::FormHandler::Field::Month';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->_set_input( 1 );
$field->validate_field;
ok( !$field->has_errors, '1 in range' );
$field->_set_input( 12 );
$field->validate_field;
ok( !$field->has_errors, '59 in range' );
$field->_set_input( 6 );
$field->validate_field;
ok( !$field->has_errors, '6 in range' );
$field->_set_input( 0  );
$field->validate_field;
ok( $field->has_errors, '0 out of range' );
$field->_set_input( 13 );
$field->validate_field;
ok( $field->has_errors, '60 out of range' );
$field->_set_input( 'March' );
$field->validate_field;
ok( $field->has_errors, 'March is not numeric' );
is( $field->errors->[0], "'March' is not a valid value", 'is error message' );


# multiple

$class = 'HTML::FormHandler::Field::Multiple';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->options([
    { value => 1, label => 'one' },
    { value => 2, label => 'two' },
    { value => 3, label => 'three' },
]);
ok( $field->options,  'options method called' );
$field->_set_input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is_deeply( $field->value, [1], 'Test 1 => [1]' );
$field->_set_input( [1] );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
ok( eq_array( $field->value, [1], 'test array' ), 'Check [1]');
$field->_set_input( [1,2] );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
ok( eq_array( $field->value, [1,2], 'test array' ), 'Check [1,2]');
$field->_set_input( [1,2,4] );
$field->validate_field;
ok( $field->has_errors, 'Test for errors 4' );
is( $field->errors->[0], "'4' is not a valid value", 'Error message' );

# password tested separately. requires a form.

# posinteger

$class = 'HTML::FormHandler::Field::PosInteger';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->_set_input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'Test value == 1' );
$field->_set_input( 0 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'Test value == 0' );
$field->_set_input( 'checked' );
$field->validate_field;
ok( $field->has_errors, 'Test non integer' );
$field->_set_input( '+10' );
$field->validate_field;
ok( !$field->has_errors, 'Test positive' );
is( $field->value, 10, 'Test value == 10' );
$field->_set_input( '-10' );
$field->validate_field;
ok( $field->has_errors, 'Test negative' );
$field->_set_input( '-10.123' );
$field->validate_field;
ok( $field->has_errors, 'Test real number ' );

# second

$class = 'HTML::FormHandler::Field::Second';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->_set_input( 0 );
$field->validate_field;
ok( !$field->has_errors, '0 in range' );
$field->_set_input( 59 );
$field->validate_field;
ok( !$field->has_errors, '59 in range' );
$field->_set_input( 12 );
$field->validate_field;
ok( !$field->has_errors, '12 in range' );
$field->_set_input( -1  );
$field->validate_field;
ok( $field->has_errors, '-1 out of range' );
$field->_set_input( 60 );
$field->validate_field;
ok( $field->has_errors, '60 out of range' );

# select

$class = 'HTML::FormHandler::Field::Select';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
ok( $field->options, 'Test for init_options failure in 0.09' );
my $options = [
    { value => 1, label => 'one' },
    { value => 2, label => 'two' },
    { value => 3, label => 'three' },
];
$field->options($options);
ok( $field->options, 'Test for set options failure' );
$field->_set_input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'Test true == 1' );
$field->_set_input( [1] );
$field->validate_field;
ok( $field->has_errors, 'Test for errors array' );
$field->_set_input( [1,4] );
$field->validate_field;
ok( $field->has_errors, 'Test for errors 4' );
is( $field->errors->[0], 'This field does not take multiple values', 'Error message' );
$field = $class->new( name => 'test_prompt', 'empty_select' => "Choose a Number",
    options => $options, required => 1 );
is( $field->num_options, 3, 'right number of options');

# textarea

$class = 'HTML::FormHandler::Field::TextArea';
use_ok( $class );
$field = $class->new( name => 'comments', cols => 40, rows => 3 );
ok( $field, 'get TextArea field');
$field->_set_input("Testing, testing, testing... This is a test");
$field->validate_field;
ok( !$field->has_errors, 'field has no errors');
$field->maxlength( 10 );
$field->validate_field;
ok( $field->has_errors, 'field has errors');
is( $field->errors->[0], 'Field should not exceed 10 characters. You entered 43',  'Test for too long' );

# text

$class = 'HTML::FormHandler::Field::Text';
use_ok( $class );
$field = $class->new( name    => 'test',);
ok( defined $field,  'new() called' );
$string = 'Some text';
$field->_set_input( $string );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, $string, 'is value input string');
$field->_set_input( '' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, undef, 'is value input string');
$field->required(1);
$field->validate_field;
ok( $field->has_errors, 'Test for errors 3' );
$field->_set_input('hello');
$field->required(1);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 'hello', 'Check again' );
$field->maxlength( 3 );
$field->validate_field;
is( $field->errors->[0], 'Field should not exceed 3 characters. You entered 5',  'Test for too long' );
$field->maxlength( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test for right length' );
$field->minlength( 10 );
$field->minlength_message('[_3] field must be at least [quant,_1,character]');
$field->validate_field;
is( $field->errors->[0], 'Test field must be at least 10 characters', 'Test not long enough' );
$field->minlength( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test just long enough' );
$field->minlength( 4 );
$field->validate_field;
ok( !$field->has_errors, 'Test plenty long enough' );
$field = $class->new( name    => 'test_not_nullable', not_nullable => 1);
$field->input('');
$field->validate_field;
is( $field->value, '', 'empty string');

# weekday

$class = 'HTML::FormHandler::Field::Weekday';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
for ( 0 .. 6 ) {
    $field->_set_input( $_ );
    $field->validate_field;
    ok( !$field->has_errors, $_ . ' is valid' );
}
$field->_set_input( -1 );
$field->validate_field;
ok( $field->has_errors, '-1 is not valid day of the week' );
$field->_set_input( 7 );
$field->validate_field;
ok( $field->has_errors, '7 is not valid day of the week' );

# year

$class = 'HTML::FormHandler::Field::Year';
use_ok( $class );
$field = $class->new( name    => 'test_field' );
ok( defined $field,  'new() called' );
$field->_set_input( 0 );
$field->validate_field;
ok( $field->has_errors, '0 is bad year' );
$field->_set_input( (localtime)[5] + 1900 );
$field->validate_field;
ok ( !$field->has_errors, 'Now is just a fine year' );
$field->_set_input( 2100 );
$field->validate_field;
ok( $field->has_errors, '2100 makes the author really old' );

# float

$class = 'HTML::FormHandler::Field::Float';
use_ok( $class );
$field = $class->new( name => 'float_test' );
ok( defined $field, 'field built' );
$field->_set_input( '2.0' );
$field->validate_field;
ok( !$field->has_errors, 'accepted 2.0 value' );
$field->_set_input( '2.000' );
$field->validate_field;
ok( $field->has_errors, 'error for 3 decimal places' );
is( $field->errors->[0], 'May have a maximum of 2 digits after the decimal point, but has 3', 'error message correct' );
$field->size(4);
$field->_set_input( '12345.00' );
$field->validate_field;
ok( $field->has_errors, 'error for size' );
is( $field->errors->[0], 'Total size of number must be less than or equal to 4, but is 7', 'error message correct' );
$field->_set_input( '12.30' );
$field->validate_field;
ok( $field->validated, 'field validated' );

# Boolean select

$class = 'HTML::FormHandler::Field::BoolSelect';
use_ok( $class );
$field = $class->new( name => 'boolselect' );
ok( defined $field, 'field built' );
$field->_set_input( '' );
$field->validate_field;
ok( !$field->has_errors, 'accepted null value' );
$field->_set_input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'accepted 1 value' );
$field->_set_input( 0 );
$field->validate_field;
ok( !$field->has_errors, 'accepted 0 value' );

done_testing;
