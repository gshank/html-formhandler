use Test::More tests => 6;

use DateTime;

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'name'    => ( type => 'Text', required => 1 );
   has_field 'age'     => ( type => 'Integer', required => 1 );
   has_field 'comment' => ( type => 'Text' );
   has_field 'address' => ( type => 'Text' );
   has_field 'city'    => ( type => 'Text' );
   has_field 'state'   => ( type => 'Text' );
   has_field 'zip'     => ( type => 'Text' );
   has_field 'cc_no'   => ( type => 'Text' );
   has_field 'cc_expires' => ( type => 'Text' );

   has '+dependency' => ( default => sub {
         [
            [ 'address', 'city', 'state', 'zip' ],
            [ 'cc_no', 'cc_expires' ],
         ] 
      }
   );

}

my $form = My::Form->new;
ok( $form, 'get form' );

my $params = {
   name => 'John Doe',
   age  => '44',
   state => 'NY',
};

my $validated = $form->validate( $params );
ok( !$validated, 'not validated' );

my @error_fields = $form->error_fields;
my $error_count = @error_fields;
is( $error_count, 3, 'number of errors is 3');

foreach my $field (@error_fields)
{
   my $name = $field->name;
   is( $field->errors->[0], 'This field is required', "required field: $name");
}


