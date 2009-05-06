#! /usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 12;
use Test::Exception;

use_ok('HTML::FormHandler::Types');
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
   


