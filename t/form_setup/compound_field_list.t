use strict;
use warnings;
use Test::More;

# tests that fields are built from a field_list sub in a compound field
{
    package MyApp::Form::Field::MyComp;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has 'state' => ( is => 'ro', isa => 'Bool', default => 0 );
    has_field 'foo';
    has_field 'bar';

    sub field_list {
        my $self = shift;
        if ( $self->state ) {
            return [ zed => 'Text' ];
        }
        return [];
    }

}

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+field_name_space' => ( default => 'MyApp::Form::Field' );
    has_field 'mimi';
    has_field 'tutu';
    has_field 'foofoo' => ( type => 'MyComp', state => 1 );

}

my $form = MyApp::Form::Test->new;
ok( $form );
ok( $form->field('foofoo.zed'), 'nested field_list field was created' );

done_testing;
