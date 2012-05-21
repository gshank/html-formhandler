use strict;
use warnings;
use Test::More;

{
   package Test::Form::Field::Phone;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Field::Compound';

   has_field 'id' => ( type => 'PrimaryKey' );
   has_field 'number';
   has_field 'comment';
}

{
   package Test::Form::Client;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'name' => (type => 'Text');
   has_field 'comment';
   has_field 'phones' => ( type => 'Repeatable' );
   has_field 'phones.contains' =>  ( type => '+Test::Form::Field::Phone');
}

my $form = Test::Form::Client->new;
$form->process(params=>{
      name => 'test client',
      phones => [
     {id=> 0, number => '123', comment => 'phone comment'}
      ]
   });
ok( $form, 'form built' );
is($form->field('phones.0.number')->value, '123', 'phone number is correct');
is($form->field('phones.0.comment')->id, 'phones.0.comment', 'phone comment id is correct');

done_testing;

