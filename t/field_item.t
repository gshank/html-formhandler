use strict;
use warnings;
use Test::More;


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
   has_field 'tags' => ( type => 'Repeatable' );
   has_field 'tags.contains' => ( type => 'Text' );
   has_field 'employer' => ( type => 'Compound' );
   has_field 'employer.name';
   has_field 'employer.country';
   has_field 'options' => ( type => 'Compound' );
   has_field 'options.flags' => ( type => 'Compound' );
   has_field 'options.flags.opt_in' => ( type => 'Boolean' );
   has_field 'options.flags.email' => ( type => 'Boolean' );
   has_field 'options.cc_cards' => ( type => 'Repeatable' );
   has_field 'options.cc_cards.type';
   has_field 'options.cc_cards.number';
   has_field 'addresses' => ( type => 'Repeatable' );
   has_field 'addresses.street';
   has_field 'addresses.city';
   has_field 'addresses.country';
   has_field 'addresses.id';

}

my $form = Structured::Form->new;
ok( $form, 'form created' );

$form->process( init_object => $struct, params => {} );

ok( !$form->validated, 'form validated');
is_deeply( $form->field('employer')->item, { name => 'TechTronix', country => 'Utopia', }, 'has item');
is_deeply( $form->field('addresses')->item, $struct->{addresses}, 'item for repeatable' );


my $fif = {
   'addresses.0.city' => 'Prime City',
   'addresses.0.country' => 'Utopia',
   'addresses.0.id' => 0,
   'addresses.0.street' => 'First Street',
   'addresses.1.city' => 'Secondary City',
   'addresses.1.country' => 'Graustark',
   'addresses.1.id' => 1,
   'addresses.1.street' => 'Second Street',
   'addresses.2.city' => 'Tertiary City',
   'addresses.2.country' => 'Atlantis',
   'addresses.2.id' => 2,
   'addresses.2.street' => 'Third Street',
   'employer.country' => 'Utopia',
   'employer.name' => 'TechTronix',
   'occupation' => 'Programmer',
   'options.cc_cards.0.number' => '4248999900001010',
   'options.cc_cards.0.type' => 'Visa',
   'options.cc_cards.1.number' => '4335992034971010',
   'options.cc_cards.1.type' => 'MasterCard',
   'options.flags.email' => 0,
   'options.flags.opt_in' => 1,
   'tags.0' => 'Perl',
   'tags.1' => 'programming',
   'tags.2' => 'Moose',
   'username' => 'Joe Blow'
};

$form->process( item => $struct, params => $fif );

ok( $form->validated, 'form processed from fif' );
is_deeply( $form->field('employer')->item, { name => 'TechTronix', country => 'Utopia', }, 'has item');
is_deeply( $form->field('addresses')->item, $struct->{addresses}, 'item for repeatable' );

done_testing;
