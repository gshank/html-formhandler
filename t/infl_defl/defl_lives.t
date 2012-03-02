use strict;
use warnings;
use Test::More;
use Test::Exception;

{
    package Form::Field::Length;
    use Moose;
    extends 'HTML::FormHandler::Field::Text';

    sub deflate {
        my $self = shift;
        $self->value;
    }
}

{
    package Form::Recording;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'length' => (type => '+Form::Field::Length');
}

{

    package Entity::Recording;
    use Moose;
    has length => ( is => 'rw' );
}

my $entity = Entity::Recording->new;
ok( $entity, 'entity built' );
my $form = Form::Recording->new(init_object => $entity);
ok( $form, 'form built' );
lives_ok( sub { $form->process({}); }, "no failure because of deflate accessing field's sub value" );

done_testing;
