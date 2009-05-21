use strict;
use warnings;
use Test::More tests => 3;


my $struct = {
   username => 'Joe Blow',
   occupation => 'Programmer',
   tags => ['Perl', 'programming', 'Moose' ],
   employer => {
      name => 'TechTronix',
      country => 'Utopia',
   },
   options => {
      flags => {
         opt_in => 1,
         email => 0,
      },
      cc_cards => [
         {
            type => 'Visa',
            number => '4248999900001010',
         },
         {
            type => 'MasterCard',
            number => '4335992034971010',
         },
      ],
   },
   addresses => [
      {
         street => 'First Street',
         city => 'Prime City',
         country => 'Utopia',
         id => 0,
      },
      {
         street => 'Second Street',
         city => 'Secondary City',
         country => 'Graustark',
         id => 1,
      },
      {
         street => 'Third Street',
         city => 'Tertiary City',
         country => 'Atlantis',
         id => 2,
      }
   ]
};


{
   package Structured::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'username';
   has_field 'occupation';
   has_field 'tags' => ( type => 'List' );
   has_field 'tags.element' => ( type => 'Text' );

}

my $form = Structured::Form->new;
ok( $form, 'form created' );

$form->process( params => $struct );

ok( $form->validated, 'form validated');

is_deeply( $form->field('tags')->value, ['Perl', 'programming', 'Moose' ],
   'list field tags has right values' );

