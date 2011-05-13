use strict;
use warnings;
use Test::More;

# This test uses roles to create forms and fields
# and nests the repeatables

{
    package Test::Form::Role::Employee;
    use HTML::FormHandler::Moose::Role;

    has_field 'first_name';
    has_field 'last_name';
    has_field 'email';
    has_field 'password';
}

{
    package Test::Form::Employee;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    with 'Test::Form::Role::Employee';
}

{
    package Test::Form::Field::Employee;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';
    
    has_field 'id' => ( type => 'PrimaryKey' );
    with 'Test::Form::Role::Employee';
}

{
    package Test::Form::Role::Office;
    use HTML::FormHandler::Moose::Role;

    has_field 'address';
    has_field 'city';
    has_field 'state';
    has_field 'zip';
    has_field 'phone';
    has_field 'fax';
    has_field 'employees' => ( type => 'Repeatable' );
    has_field 'employees.contains' =>  ( type =>  '+Test::Form::Field::Employee' );
    
}

{
    package Test::Form::Field::Office;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has_field 'id' => ( type => 'PrimaryKey' );
    with 'Test::Form::Role::Office';

}

{
    package Test::Form::Office;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'Test::Form::Role::Office';

}

{
    package Test::Form::Company;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+item_class' => (
        default => 'Company'
    );

    has_field 'name';
    has_field 'username';
    has_field 'tier';
    has_field 'type';

    has_field 'offices' => ( type => 'Repeatable' ); 
    has_field 'offices.contains' => ( type => '+Test::Form::Field::Office' );

}

my $field = Test::Form::Field::Employee->new( name => 'test_employee' );
ok( $field, 'field created' );
is( $field->num_fields, 5, 'right number of fields' );

my $form = Test::Form::Company->new;
my $params = {
    name => 'my_name',
    username => 'a_user',
    tier => 1,
    type => 'simple',
    offices => [
        {
            id => 1,
            address => '101 Main St',
            city => 'Smallville',
            state => 'CA',
            employees => [
                {
                    id => 1,
                    first_name => 'John',
                    last_name  => 'Doe',
                    email      => 'jdoe@gmail.com',
                }
            ]
        },
    ] 
};
$form->process( params => $params );
ok( $form, 'form built' );
my $fif = $form->fif;
my $value = $form->value;
my $expected = {
   'name' => 'my_name',
   'offices.0.address' => '101 Main St',
   'offices.0.city' => 'Smallville',
   'offices.0.employees.0.email' => 'jdoe@gmail.com',
   'offices.0.employees.0.first_name' => 'John',
   'offices.0.employees.0.id' => 1,
   'offices.0.employees.0.last_name' => 'Doe',
   'offices.0.employees.0.password' => '',
   'offices.0.fax' => '',
   'offices.0.id' => 1,
   'offices.0.phone' => '',
   'offices.0.state' => 'CA',
   'offices.0.zip' => '',
   'tier' => 1,
   'type' => 'simple',
   'username' => 'a_user',
};
is_deeply( $fif, $expected, 'fif is correct' );
is_deeply( $value, $params, 'value is correct' );

# following takes some pieces of above tests and tests using
# a Repeatable subclass
{

{
    package Test::Form::Field::RepEmployee;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Repeatable';
    
    has_field 'id' => ( type => 'PrimaryKey' );
    with 'Test::Form::Role::Employee';
}

{
    package Test::Form::Role::RepOffice;
    use HTML::FormHandler::Moose::Role;

    has_field 'address';
    has_field 'city';
    has_field 'state';
    has_field 'zip';
    has_field 'phone';
    has_field 'fax';
    has_field 'employees' => ( type => '+Test::Form::Field::RepEmployee' );
    
}

{
    package Test::Form::RepOffice;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'Test::Form::Role::RepOffice';

}

my $field = Test::Form::Field::RepEmployee->new( name => 'test_employee' );
ok( $field, 'field created' );
is( $field->num_fields, 5, 'right number of fields' );

my $form = Test::Form::RepOffice->new;
my $params = {
    address => '101 Main St',
    city => 'Smallville',
    state => 'CA',
    employees => [
        {
            id => 1,
            first_name => 'John',
            last_name  => 'Doe',
            email      => 'jdoe@gmail.com',
        }
    ]
};
$form->process( params => $params );
ok( $form, 'form built' );
my $fif = $form->fif;
my $value = $form->value;
my $expected = {
   'address' => '101 Main St',
   'city' => 'Smallville',
   'employees.0.email' => 'jdoe@gmail.com',
   'employees.0.first_name' => 'John',
   'employees.0.id' => 1,
   'employees.0.last_name' => 'Doe',
   'employees.0.password' => '',
   'fax' => '',
   'phone' => '',
   'state' => 'CA',
   'zip' => '',
};
is_deeply( $fif, $expected, 'fif is correct' );
is_deeply( $value, $params, 'value is correct' );

}

done_testing;
