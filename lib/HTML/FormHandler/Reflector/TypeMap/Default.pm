use MooseX::Declare;

namespace HTML::FormHandler::Reflector;

class ::TypeMap::Default
  extends ::TypeMap {
    use MooseX::Types::Moose qw(Item ArrayRef);
    use aliased 'HTML::FormHandler::Reflector::TypeMap::Entry', 'TypeMapEntry';

    has extra_entries => (
        is      => 'ro',
        isa     => ArrayRef[TypeMapEntry],
        builder => '_build_extra_entries',
    );

    has extra_subtype_entries => (
        is      => 'ro',
        isa     => ArrayRef[TypeMapEntry],
        builder => '_build_extra_subtype_entries',
    );

    method _build_extra_entries { [] }
    method _build_extra_subtype_entries { [] }

    method _build_subtype_entries {
        return [
            TypeMapEntry->new({
                type_constraint => Item,
                data            => sub { (type => 'Text') },
            }),
            @{ $self->extra_entries },
        ];
    }

    method _build_subtype_entries {
        return [@{ $self->extra_subtype_entries }];
    }
}
