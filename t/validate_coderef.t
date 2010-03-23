use strict;
use warnings;
use Test::More;
use Try::Tiny;

# this is an example of a validation that should live outside of the
# form, yet needs to be called in the form's validate routine

{

    package SignupForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has check_name_availability => (
        traits   => ['Code'],
        isa      => 'CodeRef',
        required => 1,
        handles  => { name_available => 'execute', },
    );

    has_field 'name';
    has_field 'email';

    sub validate {
        my $self = shift;
        my $name = $self->value->{name};
        if ( defined $name && length $name && !$self->name_available($name) ) {
            $self->field('name')->add_error('That name is taken already');
        }
    }

}

my $form = SignupForm->new(
    {
        check_name_availability => sub {
            my $name = shift;
            return try { &username_available($name) } catch { 0 };
        },
    }
);

ok( $form, 'form built' );

my $params = { name => 'Sam', email => 'sam@gmail.com' };

$form->process( params => $params );
ok( $form->validated, 'form validated' );

sub username_available {
    my $name = shift;
    return $name eq 'Sam' ? 1 : 0;
}


done_testing;
