use strict;
use warnings;
use Test::More tests => 3;

{

   package MyApp::Form::Roles::DateFromTo;

   use HTML::FormHandler::Moose::Role;
   has_field 'date_from' => ( type => 'Date' );
   has_field 'date_to'   => ( type => 'Date' );

   after 'validate' => sub {
      my $self = shift;
      $self->field('date_from')->add_error('From date must be before To date')
         if $self->field('date_from')->value gt $self->field('date_to')->value;
   };
}

{
   package MyApp::Form::Event;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'MyApp::Form::Roles::DateFromTo';

   has_field 'options' => ( type => 'Compound' );
   has_field 'options.cc_card' => ( type => 'Compound' );
   has_field 'options.cc_card.type' => ( apply => [ 
      { check => ['VISA', 'MasterCard'],
        message => 'Incorrect credit card type' } ] );

   sub validate_options_cc_card_type
   {
      my ( $self, $field ) = @_;
      return "got here";
   }
}
my $form = MyApp::Form::Event->new;

ok( $form, 'form created OK' );
is( $form->field('options.cc_card.type')->_validate, 'got here', 'found _validate routine' );

$form->process( params => { 'date_to.year' => '2009',
                            'date_to.month' => '07',
                            'date_to.day' => '04',
                            'date_from.year' => '2009',
                            'date_from.month' => '07',
                            'date_from.day' => '07' } );

ok( !$form->validated, 'form did not validate' );


