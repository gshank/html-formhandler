#! /usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 5;
use Test::Exception;

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

}

my $form = Test::Form->new;

ok( $form, 'get form');
$form->posint(100);

my $params = {
   test => 100,
   text_gt => 21,
   text_both => 15,
};

$form->validate($params);
ok( $form->validated, 'form validated' );
ok( !$form->field('test')->has_errors, 'no errors on MooseX type');
ok( !$form->field('text_gt')->has_errors, 'no errors on subtype');
ok( !$form->field('text_both')->has_errors, 'no errors on both');
