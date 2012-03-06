use strict;
use warnings;
use Test::More;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar';

    sub update_model {
        my $self = shift;
        my $values = $self->values;
        $values->{foo} = 'updated';
        $self->_set_value($values);
    }
}

my $form = MyApp::Form::Test->new;
my $params = { foo => 'pfoo', bar => 'pbar' };
$form->process( params => $params );
is_deeply( $form->values, { foo => 'updated', bar => 'pbar' },
    'values processed by update_model' );
$form->process( params => $params, no_update => 1 );
is_deeply( $form->values, $params,
    'values not processed by update_model' );
$form->process( params => $params );
is_deeply( $form->values, { foo => 'updated', bar => 'pbar' },
    'values processed by update_model' );

done_testing;
