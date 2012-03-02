use strict;
use warnings;
use Test::More;

    #      type     ||   p1 fif   ||   p1 value  ||  p2  validation  ||   p2 fif  ||  p2 value
    # (1) none           init_obj      init_obj      params               params      params
    # (2) infl           init_obj      init_obj      inflated             params      inflated
    # (3) defl           deflated      init_obj      params               params      params
    # (4) defl-ffv       deflated      init_obj      params               deflated    params
    # (5) infl-defl      deflated      init_obj      inflated             params      inflated
    # (6) infl_def       inflated(d)   inflated(d)   params               params      params
    # (7) defl_val       init_obj      init_obj      params               params      deflated(v)
    # (8) def-val        inflated(d)   inflated(d)   params               params      deflated(v)

    # inflated => 'inflate_method'
    # deflated => 'deflate_method'
    # inflated(d) => 'inflate_default_method'
    # deflated(v) => 'deflate_value_method'

    # An inflation method changes the format of the value used by validation
    # A deflation method changes the format of the fill-in-form string

    #    These two are "conveniences" for munging data passed in and out of a form
    #    The same effect could be achieved by modifying the value in the init_object or item
    #        before passing it in, and modifying it once returned, so it's primarily
    #        useful for database rows.
    #
    # An inflate_default method changes the 'value' retrieved from a default source
    #     (default, init_object, item)
    # A deflate_value method changes the format of the value available after validation

{
    # plain field with no inflation or deflation
    #  type     ||   p1 fif   ||   p1 value  ||  p2  validation  ||   p2 fif  ||  p2 value
    # none           init_obj      init_obj      params               params      params
    {
        package Test::Form1;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo';
        sub validate_foo {
            my ( $self, $field ) = @_;
            $self->add_error unless $field->value eq 'fromparams';
        }
    }
    my $form = Test::Form1->new;
    my $init_obj = { foo => 'initialfoo' };
    my $params = { foo => 'fromparams' };
    $form->process( init_object => $init_obj, params => {} );
    is_deeply( $form->fif, $init_obj, 'fif matches init_object' );
    is_deeply( $form->value, $init_obj, 'value matches init_object' );
    $form->process( init_object => $init_obj, params => $params );
    ok( $form->validated, 'form validated' );
    is_deeply( $form->fif, $params, 'fif matches params' );
    is_deeply( $form->value, $params, 'value matches params' );
}

{
    # field with only an inflation
    # value for validation is inflated; value returned is inflated;
    #  type     ||   p1 fif   ||   p1 value  ||  p2  validation  ||   p2 fif  ||  p2 value
    # infl           init_obj      init_obj      inflated             params      inflated
    {
        package Test::Form2;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( inflate_method => \&inflate_foo );
        sub inflate_foo { 'inflatedfoo' }
        sub validate_foo {
            my ( $self, $field ) = @_;
            $self->add_error unless $field->value eq 'inflatedfoo';
        }
    }

    my $form = Test::Form2->new;
    my $init_obj = { foo => 'initialfoo' };
    my $params = { foo => 'fromparams' };
    $form->process( init_object => $init_obj, params => {} );
    is_deeply( $form->fif, $init_obj, 'fif matches init_object' );
    is_deeply( $form->value, $init_obj, 'value matches init_object' );
    $form->process( init_object => $init_obj, params => $params );
    ok( $form->validated, 'form validated' );
    is_deeply( $form->fif, $params, 'fif matches params' );
    is_deeply( $form->value, { foo => 'inflatedfoo' }, 'value is inflated' );
}

{
    # field with only a deflation
    #  type     ||   p1 fif   ||   p1 value  ||  p2  validation  ||   p2 fif  ||  p2 value
    # defl           deflated      init_obj      params               params      params
    {
        package Test::Form3;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( deflate_method => \&deflate_foo );
        sub deflate_foo { 'deflatedfoo' }
        sub validate_foo {
            my ( $self, $field ) = @_;
            $self->add_error unless $field->value eq 'fromparams';
        }
    }
    my $form = Test::Form3->new;
    my $init_obj = { foo => 'initialfoo' };
    my $params = { foo => 'fromparams' };
    $form->process( init_object => $init_obj, params => {} );
    is_deeply( $form->fif, { foo => 'deflatedfoo' }, 'fif is deflated foo' );
    is_deeply( $form->value, { foo => 'initialfoo' }, 'value is initial foo' );
    $form->process( init_object => $init_obj, params => $params );
    ok( $form->validated, 'form validated' );
    is_deeply( $form->fif, $params, 'fif matches params' );
    is_deeply( $form->value, $params, 'value matches params' );
}


{
    # field with only a deflation; 'fif_from_value' => 1
    #  type     ||   p1 fif   ||   p1 value  ||  p2  validation  ||   p2 fif  ||  p2 value
    # defl-ffv        deflated      init_obj      params              deflated    params
    {
        package Test::Form4;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( deflate_method => \&deflate_foo,
            'fif_from_value' => 1 );
        sub deflate_foo { 'deflatedfoo' }
        sub validate_foo {
            my ( $self, $field ) = @_;
            $self->add_error unless $field->value eq 'fromparams';
        }
    }
    my $form = Test::Form4->new;
    my $init_obj = { foo => 'initialfoo' };
    my $params = { foo => 'fromparams' };
    $form->process( init_object => $init_obj, params => {} );
    is_deeply( $form->fif, { foo => 'deflatedfoo' }, 'fif is deflated foo' );
    is_deeply( $form->value, { foo => 'initialfoo' }, 'value is initial foo' );
    $form->process( init_object => $init_obj, params => $params );
    ok( $form->validated, 'form validated' );
    is_deeply( $form->fif, { foo => 'deflatedfoo' }, 'fif is deflated' );
    is_deeply( $form->value, $params, 'value matches params' );
}

{
    # field with an inflation and deflation
    # both fif and value are 'deflated'.
    #  type     ||   p1 fif   ||   p1 value  ||  p2  validation  ||   p2 fif  ||  p2 value
    # infl-defl      deflated      init_obj      inflated             params      inflated
    {
        package Test::Form5;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( inflate_method => \&inflate_foo, deflate_method => \&deflate_foo );
        sub inflate_foo { 'inflatedfoo' }
        sub deflate_foo { 'deflatedfoo' }
        sub validate_foo {
            my ( $self, $field ) = @_;
            $self->add_error unless $field->value eq 'inflatedfoo';
        }
    }

    my $form = Test::Form5->new;
    my $init_obj = { foo => 'initialfoo' };
    my $params = { foo => 'fromparams' };
    $form->process( init_object => $init_obj, params => {} );
    is_deeply( $form->fif, { foo => 'deflatedfoo' }, 'fif is deflated' );
    is_deeply( $form->value, $init_obj, 'value is initial' );
    $form->process( init_object => $init_obj, params => $params );
    ok( $form->validated, 'form validated' );
    is_deeply( $form->fif, $params, 'fif matches params' );
    is_deeply( $form->value, { foo => 'inflatedfoo' }, 'value is inflated' );
}

{
    # field with only 'inflate_default'
    #  type     ||   p1 fif   ||   p1 value  ||  p2  validation  ||   p2 fif  ||  p2 value
    # infl_def       inflated      inflated      params               params      params
    {
        package Test::Form6;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( inflate_default_method => sub { 'infl_def_foo' } );
        sub validate_foo {
            my ( $self, $field ) = @_;
            $self->add_error unless $field->value eq 'fromparams';
        }
    }
    my $form = Test::Form6->new;
    my $init_obj = { foo => 'initialfoo' };
    my $params = { foo => 'fromparams' };
    $form->process( init_object => $init_obj, params => {} );
    is_deeply( $form->fif, { foo => 'infl_def_foo' }, 'fif matches inflate_default' );
    is_deeply( $form->value, { foo => 'infl_def_foo' }, 'value matches init_object' );
    $form->process( init_object => $init_obj, params => $params );
    ok( $form->validated, 'form validated' );
    is_deeply( $form->fif, $params, 'fif matches params' );
    is_deeply( $form->value, $params, 'value matches params' );
}

{
    # field with only a 'deflate_value' method
    #  type     ||   p1 fif   ||   p1 value  ||  p2  validation  ||   p2 fif  ||  p2 value
    # defl_val       init_obj      init_obj      params               params      deflated
    {
        package Test::Form7;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( deflate_value_method => sub { 'defl_val_foo' } );
        sub validate_foo {
            my ( $self, $field ) = @_;
            $self->add_error unless $field->value eq 'fromparams';
        }
    }
    my $form = Test::Form7->new;
    my $init_obj = { foo => 'initialfoo' };
    my $params = { foo => 'fromparams' };
    $form->process( init_object => $init_obj, params => {} );
    is_deeply( $form->fif, $init_obj, 'fif matches init_object' );
    is_deeply( $form->value, $init_obj, 'value matches init_object' );
    $form->process( init_object => $init_obj, params => $params );
    ok( $form->validated, 'form validated' );
    is_deeply( $form->fif, $params, 'fif matches params' );
    is_deeply( $form->value, { foo => 'defl_val_foo' }, 'value is deflated by deflate_value' );
}

{
    # field with 'inflate_default' and a 'deflate_value' method
    #  type     ||   p1 fif   ||   p1 value  ||  p2  validation  ||   p2 fif  ||  p2 value
    # def-val        inflated      inflated      params               params      deflated
    {
        package Test::Form8;
        use HTML::FormHandler::Moose;
        extends 'HTML::FormHandler';

        has_field 'foo' => ( inflate_default_method => sub { 'infl_def_foo' },
                             deflate_value_method => sub { 'defl_val_foo' } );
        sub validate_foo {
            my ( $self, $field ) = @_;
            $self->add_error unless $field->value eq 'fromparams';
        }
    }
    my $form = Test::Form8->new;
    my $init_obj = { foo => 'initialfoo' };
    my $params = { foo => 'fromparams' };
    $form->process( init_object => $init_obj, params => {} );
    is_deeply( $form->fif, { foo => 'infl_def_foo' }, 'fif matches init_object' );
    is_deeply( $form->value, { foo => 'infl_def_foo' }, 'value matches init_object' );
    $form->process( init_object => $init_obj, params => $params );
    ok( $form->validated, 'form validated' );
    is_deeply( $form->fif, $params, 'fif matches params' );
    is_deeply( $form->value, { foo => 'defl_val_foo' }, 'value from deflate_value' );
}


done_testing;
