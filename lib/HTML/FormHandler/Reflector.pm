package HTML::FormHandler::Reflector;

use Moose;
use MooseX::Types::Moose qw/Object Str/;
use HTML::FormHandler::Reflector::Types qw/FieldBuilder/;
use aliased 'HTML::FormHandler::Reflector::Meta::Attribute::NoField';
use aliased 'HTML::FormHandler::Reflector::Meta::Attribute::Field';
use aliased 'HTML::FormHandler::Reflector::FieldBuilder::Default', 'DefaultFieldBuilder';

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

has field_builder => (
    is      => 'ro',
    isa     => FieldBuilder,
    default => sub { DefaultFieldBuilder->new },
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

    # XXX: at some point we probably want to reflect a form instance out of a
    # metaclass, but most of the logic is the same really, so for now we just
    # rely on the formhandler metaclass trait to be there
    $target->add_to_field_list($_)
        for $self->reflect_class($self->metaclass);

    return $target;
}

sub reflect_class {
    my ($self, $metaclass) = @_;

    return map {
        $self->reflect_attribute($_)
    } sort { # XXX: i suppose fields might want to decide on their order themself, probably using the
             # Form trait and either some numeric order, or something like "after $that field". we
             # quite possibly also want to accept a custom sort function as well.
        $a->has_insertion_order && $b->has_insertion_order ? $a->insertion_order <=> $b->insertion_order
      : $a->has_insertion_order                            ? -1
      : $b->has_insertion_order                            ?  1
      :                                                       0
    } $metaclass->get_all_attributes;
}

sub reflect_attribute {
    my ($self, $attr) = @_;
    return $self->field_builder->resolve($attr);
}

__PACKAGE__->meta->make_immutable;

1;
