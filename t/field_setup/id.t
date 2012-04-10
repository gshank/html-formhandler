use strict;
use warnings;
use Test::More;

# test dynamic field ID
{
    package My::DynamicFieldId;
    use Moose::Role;
    around 'id' => sub {
        my $orig = shift;
        my $self = shift;
        my $form_name = $self->form->name;
        return $form_name . "." . $self->full_name;
    };
}
{

    package My::CustomIdForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'F123' );
    has '+html_prefix' => ( default => 1 );
    has '+field_traits' => ( default => sub { ['My::DynamicFieldId'] } );

    has_field 'foo';
    has_field 'bar';
}
my $form = My::CustomIdForm->new;
is( $form->field('foo')->id, 'F123.foo', 'got correct id' );

# test providing a coderef for field ID building
{
    package MyApp::CustomId;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_update_subfields {
        { all => { build_id_method => \&custom_id } }
    }
    has_field 'foo' => ( type => 'Compound' );
    has_field 'foo.one';
    has_field 'foo.two';
    has_field 'foo.three';
    sub custom_id {
        my $self = shift;
        my $full_name = $self->full_name;
        $full_name =~ s/\./_/g;
        return $full_name;
    }
}
$form = MyApp::CustomId->new;
ok( $form, 'form built' );
is( $form->field('foo.two')->id, 'foo_two', 'got correct id' );

done_testing;
