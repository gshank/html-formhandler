use Test::More;

use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = HTML::FormHandler::I18N->get_handle('en_en');

use DateTime;

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'name'    => ( required => 1 );
   has_field 'age'     => ( required => 1 );
   has_field 'comment';
   has_field 'address';
   has_field 'city';
   has_field 'state';
   has_field 'zip';
   has_field 'cc_no';
   has_field 'cc_expires';

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

my $validated = $form->process( $params );
ok( !$validated, 'not validated' );

my @error_fields = $form->error_fields;
my $error_count = @error_fields;
is( $error_count, 3, 'number of errors is 3');

foreach my $field (@error_fields)
{
   my $name = $field->name;
   is( $field->errors->[0], $field->label . ' field is required', "required field: $name");
}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar';
    has_field 'baz';

   has '+dependency' => ( default => sub {
         [
            [ 'foo', 'bar' ],
         ]
      }
   );

}

{
    package Test::Obj;
    use Moose;
    has 'fox' => ( is => 'ro' );
    has 'dog' => ( is => 'ro' );
}

$form = Test::Form->new;
my $obj = Test::Obj->new( fox => 'test' );
$form->process( params => { foo => $obj } );
ok( !$form->validated, 'form did not validate' );
my @errors = $form->errors;
is( $errors[0], 'Bar field is required', 'dependency error is correct');

done_testing;
