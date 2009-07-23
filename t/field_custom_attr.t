use strict;
use warnings;
use Test::More tests => 3;

use lib ('t/lib');

{
   package Form::RoleForm;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   use HTML::FormHandler::Field;

   sub BUILD 
   {
      my $self = shift;
      my $fmeta = HTML::FormHandler::Field->meta;
      $fmeta->make_mutable;
      Moose::Util::apply_all_roles( $fmeta, ('Field::Role::Test'));
      $fmeta->make_immutable;
   }
   has_field 'bar';
   has_field 'foo';
}

{
   package Field::Role::Test;

   use Moose::Role;

   has 'foo_attr' => ( isa => 'Str', is => 'rw' );
   has 'bar_attr' => ( isa => 'Str', is => 'rw' );
}

my $form = Form::RoleForm->new;

ok( $form, 'form created' );
ok( $form->field('bar')->foo_attr('test'), 'has extra attribute' );
is( $form->field('bar')->foo_attr, 'test', 'attribute was set' );

