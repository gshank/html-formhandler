#! /usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 18;
use Test::Exception;

use HTML::FormHandler::Types (':all');

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
};

$form->process($params);
ok( !$form->validated, 'form did not validate' );
ok( $form->field('test')->has_errors, 'errors on MooseX type');
ok( $form->field('text_gt')->has_errors, 'errors on subtype');
ok( $form->field('text_both')->has_errors, 'errors on both');
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
   
my $field = HTML::FormHandler::Field->new( name => 'Test1', apply => [ State ] );
ok( $field, 'created field with type' );
$field->input('GG');
ok( !$field->process, 'field did not validate');
is( $field->errors->[0], 'Not a valid state', 'correct error message for state' );
$field->input('NY');
ok( $field->process, 'state field validated');
SKIP: {
   eval { require Email::Valid };
   skip "Email::Valid not installed", 3 if $@;
   $field = HTML::FormHandler::Field->new( name => 'Test', apply => [ Email ] );
   $field->input('gail@gmail.com');
   ok( $field->process, 'email field validated' );
   ok( !$field->has_errors, 'email field is valid');
   $field->input('not_an_email');
   $field->process;
   is( $field->errors->[0], 'Email is not valid', 'error from email' );
}




