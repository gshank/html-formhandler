use Test::More;
use lib 't/lib';


{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'testform_' );
   has_field 'optname' => ( temp => 'First' );
   has_field 'reqname' => ( required => 1 );
   has_field 'somename';
}


my $form = My::Form->new( init_object => {reqname => 'Starting Perl',
                                       optname => 'Over Again' } );
ok( $form, 'non-db form created OK');
is( $form->field('optname')->value, 'Over Again', 'get right value from form');
$form->process({});
ok( !$form->validated, 'form validated' );
is( $form->field('reqname')->fif, 'Starting Perl', 
                      'get right fif with init_object');

{
   package My::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'initform_' );
   has_field 'foo';
   has_field 'bar';
   has_field 'baz';
   has_field 'bax' => ( default => 'default_bax' );
   has '+init_object' => ( default => sub { { foo => 'initfoo' } } );
   sub default_bar { 'init_value_bar' }
   sub init_value_baz { 'init_value_baz' }
}

$form = My::Form->new;
ok( $form->field('foo')->value, 'initfoo' );
ok( $form->field('bar')->value, 'init_value_bar' );
ok( $form->field('baz')->value, 'init_value_baz' );
ok( $form->field('bax')->value, 'default_bax' );

{
    package Mock::Object;
    use Moose;
    has 'foo' => ( is => 'rw' );
    has 'bar' => ( is => 'rw' );
    has 'baz' => ( is => 'rw' );
}
{
    package Test::Object;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Model::Object';
    has_field 'foo';
    has_field 'bar';
    has_field 'baz';
    has_field 'bax' => ( default => 'bax_from_default' );
    has_field 'zero' => ( type => 'PosInteger', default => 0 );
    has_field 'foo_list' => ( type => 'Multiple', default => [1,3],
       options => [{ value => 1, label => 'One'}, 
                   { value => 2, label => 'Two'},
                   { value => 3, label => 'Three'},
                  ] 
    );

    sub init_object {
        { bar => 'initbar' }
    }

}

my $obj = Mock::Object->new( foo => 'myfoo', bar => 'mybar', baz => 'mybaz' );

$form = Test::Object->new;
$form->process( item => $obj, item_id => 1, params => {} );
is( $form->field('foo')->value, 'myfoo', 'field value from item');
is( $form->field('bar')->value, 'mybar', 'field value from item');
is( $form->field('bax')->value, 'bax_from_default', 'non-item field value from default' );
is( $form->field('zero')->value, 0, 'zero default works');
is_deeply( $form->field('foo_list')->value, [1,3], 'multiple default works' );

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has 'quuz' => ( is => 'ro', default => 'some_quux' );
    has_field 'foo';
    has_field 'bar';

    sub init_object {
        my $self = shift;
        return { foo => $self->quuz, bar => 'bar!' };
    }
}
$form = Test::Form->new;
is( $form->field('foo')->value, 'some_quux', 'field initialized by init_object' );


{
    package Mock::Object;
    use Moose;
    has 'meow' => ( is => 'rw' );
}
{
    package Test::Object;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Model::Object';
    has_field 'meow' => ( default => 'this_should_get_overridden' );

}

$obj = Mock::Object->new( meow => 'the_real_meow' );

$form = Test::Object->new;
$form->process( item => $obj, item_id => 1, params => {} );
is( $form->field('meow')->value, 'the_real_meow', 'defaults should not override actual item values');

done_testing;
