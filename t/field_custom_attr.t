use strict;
use warnings;
use Test::More tests => 4;

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

