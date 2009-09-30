use strict;
use warnings;
use Test::More;

{
    package Foo;
    use Moose;
    use MooseX::Types::Moose qw/Str Num/;
    use namespace::autoclean;

    has bar => (is => 'ro', isa => Str);
    has baz => (is => 'rw', isa => Num);

    has corge => (
        traits   => [qw(FormHandler::NoField)],
        is       => 'rw',
        init_arg => undef,
        lazy     => 1,
        default  => sub { shift->bar },
    );

    has fred => (
        traits   => [qw(FormHandler::Field)],
        is       => 'rw',
        isa      => Str,
        required => 1,
        form     => {
            label => 'Grault',
            type  => 'TextArea',
        },
    );

    __PACKAGE__->meta->make_immutable;
}

{
    package FooForm;
    use Moose;
    use HTML::FormHandler::Reflector;
    use HTML::FormHandler::Moose;

    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::Simple';

    my $reflector = HTML::FormHandler::Reflector->new({
        metaclass    => Foo->meta,
        target_class => __PACKAGE__,
    });

    $reflector->reflect;

    has_field submit => (type => 'Submit');

    __PACKAGE__->meta->make_immutable;
}

my $form = FooForm->new;
isa_ok($form, 'HTML::FormHandler');

my @fields = $form->fields;
is_deeply(
    [sort map { $_->name } @fields],
    [qw/baz fred submit/],
    'form has fields for every attribute',
);

done_testing;
