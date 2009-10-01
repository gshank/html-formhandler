use strict;
use warnings;
use Test::More;

use lib ('t/lib');

{
   package Form::RoleForm;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   use HTML::FormHandler::Field;

   after 'BUILDARGS' => sub {
      my $fmeta = HTML::FormHandler::Field->meta;
      $fmeta->make_mutable;
      Moose::Util::apply_all_roles( $fmeta, ('Field::Role::Test'));
      $fmeta->make_immutable;
   };
   has_field 'bar' => (foo_attr => 'xxx');
   has_field 'foo' => (bar_attr => 'yyy');;
}

{
   package Field::Role::Test;

   use Moose::Role;

   has 'foo_attr' => ( isa => 'Str', is => 'rw' );
   has 'bar_attr' => ( isa => 'Str', is => 'rw' );
}

my $form = Form::RoleForm->new;

ok( $form, 'form created' );
is( $form->field('bar')->foo_attr, 'xxx', 'attribute set ok' );
ok( $form->field('bar')->foo_attr('test'), 'has extra attribute' );
is( $form->field('bar')->foo_attr, 'test', 'attribute was set' );

{
    package My::Render;
    use Moose::Role;
    has 'my_attr' => ( is => 'rw', isa => 'Str' );
    sub html {
        my $self = shift;
        return "<h2>Pick something, quick!</h2>"; 
    }

}

use HTML::FormHandler;
$form = HTML::FormHandler->new( field_list => [
        foo => { type => 'Text', required => 1 },
        baz => { type => 'Display', traits => ['My::Render'], my_attr => 'something' },
        bar => { type => 'Select', options => [{value => 1, label => 'bar1'},
            {value => 2, label => 'bar2' }] },
    ],
);

ok( $form, 'dynamic form created' );
is( $form->field('baz')->my_attr, 'something', 'attribute added by trait was set' );
is( $form->field('baz')->html, "<h2>Pick something, quick!</h2>", 'new method works' );


done_testing;
