use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has 'condition' => ( is => 'rw' );

    has_field 'foo';
    has_field 'bar';

    sub validate {
        my $self = shift;
        unless( $self->condition eq 'my_cond' ) {
            $self->add_form_error('Form is invalid');
        }
    }

}

my $form = Test::Form->new;
ok( $form, 'form built' );

$form->process( condition => 'not_my_cond', params => {} );
ok( !$form->ran_validation, 'validation not performed yet' );
ok( !$form->has_errors, 'no errors in form' );

$form->process( condition => 'not_my_cond', params => { foo => 'test', bar => 'boo' } );
ok( $form->ran_validation, 'validation performed' );
ok( $form->has_errors, 'errors in form' );

my $rendered = $form->render;
like( $rendered, qr/error_message/, 'form error rendered' );
like( $rendered, qr/form_errors/, 'form error rendered' );

{
    package Test::Form2;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::Simple';

    has 'condition' => ( is => 'rw' );

    has_field 'foo';
    has_field 'bar';

    sub validate {
        my $self = shift;
        unless( $self->condition eq 'my_cond' ) {
            $self->add_form_error('Form is invalid');
        }
    }

}

$form = Test::Form2->new;
ok( $form, 'form built' );

$form->process( condition => 'not_my_cond', params => {} );
ok( !$form->ran_validation, 'validation not performed yet' );
ok( !$form->has_errors, 'no errors in form' );

$form->process( condition => 'not_my_cond', params => { foo => 'test', bar => 'boo' } );
ok( $form->ran_validation, 'validation performed' );
ok( $form->has_errors, 'errors in form' );

$rendered = $form->render;
like( $rendered, qr/error_message/, 'form error rendered' );
like( $rendered, qr/form_errors/, 'form error rendered' );

{
    package Test::Form3;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_form' => ( default => 'Table' );
    has '+widget_wrapper' => ( default => 'Table' );

    has 'condition' => ( is => 'rw' );

    has_field 'foo';
    has_field 'bar';

    sub validate {
        my $self = shift;
        unless( $self->condition eq 'my_cond' ) {
            $self->add_form_error('Form is invalid');
        }
    }

}

$form = Test::Form3->new;
ok( $form, 'form built' );

$form->process( condition => 'not_my_cond', params => { foo => 'test', bar => 'boo' } );
ok( $form->has_errors, 'errors in form' );

$rendered = $form->render;
like( $rendered, qr/error_message/, 'form error rendered' );
like( $rendered, qr/form_errors/, 'form error rendered' );

{
    package Test::Form4;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::Table';

    has 'condition' => ( is => 'rw' );

    has_field 'foo';
    has_field 'bar';

    sub validate {
        my $self = shift;
        unless( $self->condition eq 'my_cond' ) {
            $self->add_form_error('Form is invalid');
        }
    }

}

$form = Test::Form3->new;
ok( $form, 'form built' );

$form->process( condition => 'not_my_cond', params => { foo => 'test', bar => 'boo' } );
ok( $form->has_errors, 'errors in form' );

$rendered = $form->render;
like( $rendered, qr/error_message/, 'form error rendered' );
like( $rendered, qr/form_errors/, 'form error rendered' );

done_testing;
