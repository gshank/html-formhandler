use Test::More tests => 6;

use DateTime;

{
   package My::Form;
   use Moose;
   extends 'HTML::FormHandler';

   sub profile {
      return {
         required => {
             name    => 'Text',
             age     => 'Integer',
         },
         optional => {
             comment  => 'Text',
             address  => 'Text',
             city     => 'Text',
             state    => 'Text',
             zip      => 'Text', 
             cc_no    => 'Text',
             cc_expires => 'Text',
         },
         dependency => [
            [ 'address', 'city', 'state', 'zip' ],
            [ 'cc_no', 'cc_expires' ],
         ],
      };
   }

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


