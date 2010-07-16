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

{
    package MyApp::Field::Test;
    use Moose::Role;
    sub got_here { 1 }
}

my $form = Form::RoleForm->new( field_traits => ['MyApp::Field::Test'] );

ok( $form, 'form created' );
is( $form->field('bar')->foo_attr, 'xxx', 'attribute set ok' );
ok( $form->field('bar')->foo_attr('test'), 'has extra attribute' );
is( $form->field('bar')->foo_attr, 'test', 'attribute was set' );
ok( $form->field('foo')->got_here  && $form->field('bar')->got_here, 'base field role applied' );

{
    package My::Render;
    use Moose::Role;
    has 'my_attr' => ( is => 'rw', isa => 'Str' );
    sub html {
        my $self = shift;
        return "<h2>Pick something, quick!</h2>";
    }

}

{
    package MyApp::Widget::Field::Text;
    use Moose::Role;
    has 'widget_attr' => ( is => 'rw' );
    sub render {
       my $self = shift;
       return $self->widget_attr || 'empty attr';
    }
}

use HTML::FormHandler;
$form = HTML::FormHandler->new(
    widget_name_space => ['MyApp::Widget'],
    field_list => [
        foo => { type => 'Text', required => 1, widget_attr => 'A Test!' },
        baz => { type => 'Display', traits => ['My::Render'], my_attr => 'something' },
        bar => { type => 'Select', options => [{value => 1, label => 'bar1'},
            {value => 2, label => 'bar2' }] },
    ],
);

ok( $form, 'dynamic form created' );
is( $form->field('baz')->my_attr, 'something', 'attribute added by trait was set' );
is( $form->field('baz')->html, "<h2>Pick something, quick!</h2>", 'new method works' );
is( $form->field('foo')->widget_attr, 'A Test!', 'widget attribute applied' );
is( $form->field('foo')->render, 'A Test!', 'widget renders using attribute' );


done_testing;
