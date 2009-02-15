use strict;
use warnings;
use Test::More tests => 13;

use_ok( 'HTML::FormHandler' );

{
   package My::Form;
   use Moose;
   extends 'HTML::FormHandler';
   has '+name' => ( default => 'testform_' );
   sub field_list {
       return {
           fields    => {
               reqname     => {
                  type => 'Text',
                  required => 1,
                  required_message => 'You must supply a reqname',
               },
               fruit       => 'Select',
               optname     => 'Text',
               silly_name  => {
                  type =>'Text',
                  validate_meth => 'valid_silly'
               }
           },
       };
   }
   sub options_fruit {
       return (
           1   => 'apples',
           2   => 'oranges',
           3   => 'kiwi',
       );
   }
   sub valid_silly
   {
      my ( $self, $field ) = @_;
      $field->add_error( 'Not a valid silly_name' )
            unless $field->value eq 'TeStInG';
   }
}

my $form = My::Form->new;

my $bad_1 = {
    optname => 'not req',
    fruit   => 4,
    silly_name => 'what??',
};

ok( !$form->validate( $bad_1 ), 'bad 1' );

ok( $form->has_error, 'form has error' );

ok( $form->field('fruit')->has_errors, 'fruit has error' );

ok( $form->field('reqname')->has_errors, 'reqname has error' );

ok( !$form->field('optname')->has_errors, 'optname has no error' );
ok( $form->field('silly_name')->has_errors, 'silly_name has error' );
ok( $form->has_errors, 'form has errors' );

my @fields = $form->error_fields;
ok( @fields, 'error fields' );

my @errors = $form->errors;
is_deeply( \@errors, ['\'4\' is not a valid value',
                     'You must supply a reqname',
                     'Not a valid silly_name' ],
     'errors from form' );

is( $form->num_errors, 3, 'number of errors' );

my @field_names = $form->error_field_names;
is_deeply( \@field_names, 
           [ 'fruit', 'reqname', 'silly_name' ],
           'error field names' );

is( $form->field('fruit')->id, "testform_fruit", 'field has id' ); 

$form->clear_state;


