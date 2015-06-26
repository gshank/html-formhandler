use strict;
use warnings;
use Test::More;
use Test::Exception;

use HTML::FormHandler::Types (':all');

use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = 'en_en';

{
  package Test::Form;
  use HTML::FormHandler::Moose;
  extends 'HTML::FormHandler';
  use HTML::FormHandler::Types (':all');
  use Moose::Util::TypeConstraints;

  subtype 'GreaterThan10'
     => as 'Int'
     => where { $_ > 10 }
     => message { "This number ($_) is not greater than 10" };

  has 'posint' => ( is => 'rw', isa => PositiveInt);
  has_field 'test' => ( apply => [ PositiveInt ] );
  has_field 'text_gt' => ( apply=> [ 'GreaterThan10' ] );
  has_field 'text_both' => ( apply => [ PositiveInt, 'GreaterThan10' ] );
  has_field 'field_wtype' => ( apply => [
      { type => PositiveInt, message => 'Not a positive number' } ] );
  has_field 'state' => ( apply => [ State ] );

}

my $form = Test::Form->new;

ok( $form, 'get form');
$form->posint(100);

my $params = {
   test => '-100',
   text_gt => 5,
   text_both => 6,
   state => 'GG',
   field_wtype => '-10',
};

$form->process($params);
ok( !$form->validated, 'form did not validate' );
ok( $form->field('test')->has_errors, 'errors on MooseX type');
ok( $form->field('text_gt')->has_errors, 'errors on subtype');
ok( $form->field('text_both')->has_errors, 'errors on both');
ok( $form->field('field_wtype')->has_errors, 'errors on type with message');
ok( $form->field('state')->has_errors, 'errors on state' );

$params = {
   test => 100,
   text_gt => 21,
   text_both => 15,
   state => 'NY',
};

$form->process($params);
ok( $form->validated, 'form validated' );
ok( !$form->field('test')->has_errors, 'no errors on MooseX type');
ok( !$form->field('text_gt')->has_errors, 'no errors on subtype');
ok( !$form->field('text_both')->has_errors, 'no errors on both');
ok( !$form->field('state')->has_errors, 'no errors on state' );

# State
my $field = HTML::FormHandler::Field->new( name => 'Test1', apply => [ State ] );
$field->build_result;
ok( $field, 'created field with type' );
$field->_set_input('GG');
ok( !$field->validate_field, 'field did not validate');
is( $field->errors->[0], 'Not a valid state', 'correct error message for State' );
$field->_set_input('NY');
ok( $field->validate_field, 'state field validated');
# Email
$field = HTML::FormHandler::Field->new( name => 'Test', apply => [ Email ] );
$field->build_result;
$field->_set_input('gail@gmail.com');
ok( $field->validate_field, 'email field validated' );
ok( !$field->has_errors, 'email field is valid');
$field->_set_input('not_an_email');
$field->validate_field;
is( $field->errors->[0], 'Email is not valid', 'error from Email' );

my @test = (
    IPAddress => \&IPAddress =>
    [qw(0.0.0.0 01.001.0.00 198.168.0.101 255.255.255.255)],
    [qw(1 2.33 4.56.789 198.300.0.101 0.-1.13.255)],
        'Not a valid IP address',
    NoSpaces => \&NoSpaces =>
    [qw(a 1 _+~ *), '#'], ['a b', "x\ny", "foo\tbar"],
        'Must not contain spaces',
    WordChars => \&WordChars =>
    [qw(abc 8 ___ 90_i 0)],
    ['a b', "x\ny", "foo\tbar", 'c++', 'C#', '$1,000,000'],
        'Must be made up of letters, digits, and underscores',
    NotAllDigits => \&NotAllDigits =>
        [qw(a 1a . a=1 1.23), 'a 1'], [qw(0 1 12 03450)],
        'Must not be all digits',
# does not work at all!!!
#    Printable => \&Printable =>
#        [qw(a 1 $ % *), '# ?'], [0x00, "foo\tbar", "x\ny"],
#        'Field contains non-printable characters',
    SingleWord => \&SingleWord =>
        [qw(a 1a _ a_1 1_234)], ['a b', '1.23', 'a=1'],
        'Field must contain a single word',
);

while (my ($name, $type, $good, $bad, $error_msg) = splice @test, 0, 5) {
    $field = HTML::FormHandler::Field->new(name => 'Test', apply => [&$type]);
    $field->build_result;
    for (@$good) {
        $field->_set_input($_);
        ok($field->validate_field, "$name validated");
        ok(!$field->has_errors, "$name field is valid");
    }
    for (@$bad) {
        $field->_set_input($_);
        ok(!$field->validate_field, "$name validation failed");
        is($field->errors->[0], $error_msg, "error from $name");
    }
}

@test = (
    Lower => \&Lower =>
    [A => 'a', AB => 'ab', Abc => 'abc', abc => 'abc', 'A-z' => 'a-z', '1 + X' => '1 + x'],
    Upper => \&Upper =>
    [a => 'A', ab => 'AB', Abc => 'ABC', ABC => 'ABC', 'A-z' => 'A-Z', '1 + x' => '1 + X'],
);

while (my ($name, $type, $trans) = splice @test, 0, 3) {
    my @trans = @$trans;
    $field = HTML::FormHandler::Field->new(name => 'Test', apply => [&$type]);
    $field->build_result;
    while (my ($from, $to) = splice @trans, 0, 2) {
    $field->_set_input($from);
    ok($field->validate_field, "$name validated");
    is($field->value, $to , "$name field transformation");
    }
}

SKIP: {
    eval { require Type::Tiny };

    skip "Type::Tiny not installed", 9 if $@;

    {
        package Test::Form::Type::Tiny;

        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        my $NUM = Type::Tiny->new(
            name       => "Number",
            constraint => sub { $_ =~ /^\d+$/ },
            message    => sub { "$_ ain't a number" },
        );

        has_field 'test_a' => ( apply => [ $NUM ] );
        has_field 'test_b' => ( apply => [ { type => $NUM } ] );
    }

    my $form = Test::Form::Type::Tiny->new;

    ok($form, 'get form');

    my $params = {
        test_a => 'str1',
        test_b => 'str2',
    };
    $form->process($params);
    ok( !$form->validated, 'form did not validate' );
    ok( $form->field('test_a')->has_errors, 'errors on Type::Tiny type');
    ok( $form->field('test_b')->has_errors, 'errors on Type::Tiny type');
    is( $form->field('test_a')->errors->[0], "str1 ain't a number", 'error from Type::Tiny' );
    is( $form->field('test_b')->errors->[0], "str2 ain't a number", 'error from Type::Tiny' );

    $params = {
        test_a => '123',
        test_b => '456',
    };
    $form->process($params);
    ok( $form->validated, 'form validated' );
    ok( !$form->field('test_a')->has_errors, 'no errors on Type::Tiny type');
    ok( !$form->field('test_b')->has_errors, 'no errors on Type::Tiny type');
}

done_testing;
