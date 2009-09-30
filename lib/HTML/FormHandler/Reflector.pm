package HTML::FormHandler::Reflector;

use Moose;
use MooseX::Types::Moose qw/Object Str/;
use aliased 'HTML::FormHandler::Reflector::Meta::Attribute::NoField';
use aliased 'HTML::FormHandler::Reflector::Meta::Attribute::Field';

use namespace::autoclean;

has metaclass => (
    is       => 'ro',
    isa      => Object,
    required => 1,
);

has target_class => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has target_metaclass => (
    is      => 'ro',
    isa     => Object,
    lazy    => 1,
    builder => '_build_target_metaclass',
);

sub _build_target_metaclass {
    my ($self) = @_;

    my $meta = Class::MOP::class_of($self->target_class);
    return $meta if $meta;

    $meta = Moose::Meta::Class->create(
        $self->target_class => (
            superclasses => ['HTML::FormHandler'],
            methods      => {
                meta => sub { $meta },
            },
        ),
    );

    $meta = Moose::Util::MetaRole::apply_metaclass_roles(
        for_class       => $meta,
        metaclass_roles => ['HTML::FormHandler::Meta::Role'],
    );

    return $meta;
}

sub reflect {
    my ($self) = @_;
    my $target = $self->target_metaclass;

    $target->add_to_field_list($_)
        for $self->reflect_class($self->metaclass);

    return $target;
}

sub reflect_class {
    my ($self, $metaclass) = @_;

    return map {
        $self->reflect_attribute($_)
    } $metaclass->get_all_attributes;
}

sub reflect_attribute {
    my ($self, $attr) = @_;

    return () if $attr->does(NoField);

    my %field = (
        name     => $attr->name,
        required => $attr->is_required,
        type     => 'Text', # XXX: we need a typemap, and something with sane defaults for it
    );

    if ($attr->has_type_constraint) {
        my $tc = $attr->type_constraint;

        $field{apply} = [
            { transform => ($tc->has_coercion
                            ? sub { $tc->coerce($_[0]) }
                            : sub { }) },
            { check   => sub { $tc->check($_[0]) },
              message => 'invalid' }, # XXX: tweak formhandler to not expect people to know their error message in advance
        ];
    }

    %field = (%field, %{ $attr->form || {} })
        if $attr->does(Field);

    return \%field;
}

__PACKAGE__->meta->make_immutable;

1;
