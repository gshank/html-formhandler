use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has 'secret' => ( is => 'rw', default => 'wrong' );

    has_field 'foo';
    has_field 'bar';
  
    sub validate_foo {
        my ( $self, $field ) = @_;
        $field->add_error('Not a valid foo')
            if( $field->value eq 'test' );
    }
    sub validate_bar {
        my ( $self, $field ) = @_;
        $field->add_error('Not a valid bar')
            if( $field->value eq 'bad_bar' );
    }
    sub validate {
        my $self = shift;
        $self->add_form_error('Try again')
           if( $self->field('foo')->value ne $self->secret ); 
    }
}

my $form = Test::Form->new;
ok( $form, 'form builds' );
$form->process( params => {} );
my $params = {
    foo => 'test',
    bar => 'bad_bar',
}; 
$form->process( secret => 'yikes', params => $params );
ok( !$form->validated, 'form did not validate' );
$form->process( secret => 'my_bar', params => { bar => 'my_bar', foo => 'my_foo' } );
my @errors = $form->errors;
is( $errors[0], 'Try again', 'form error' );
$form->process( secret => 'my_foo', params => { bar => 'my_bar', foo => 'my_foo' } );
ok( $form->validated, 'form validated' );
ok( !$form->has_form_errors, 'form errors are gone' );
    
done_testing;
