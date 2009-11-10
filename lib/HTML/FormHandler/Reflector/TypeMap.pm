use MooseX::Declare;

class HTML::FormHandler::Reflector::TypeMap {
    use Scalar::Util qw(refaddr);
    use Hash::Util::FieldHash::Compat qw(idhash);

    use MooseX::Types::Moose qw(ArrayRef);
    use HTML::FormHandler::Reflector::Types qw(TypeMapEntry);

    has entries => (
        is      => 'ro',
        isa     => ArrayRef[TypeMapEntry],
        lazy    => 1,
        builder => '_build_entries',
    );

    has subtype_entries => (
        is      => 'ro',
        isa     => ArrayRef[TypeMapEntry],
        lazy    => 1,
        builder => '_build_subtype_entries',
    );

    has _sorted_entries => (
        is      => 'ro',
        isa     => ArrayRef[ArrayRef[TypeMapEntry]],
        lazy    => 1,
        builder => '_build__sorted_entries',
    );

    method _build_entries { [] }
    method _build_subtype_entries { [] }

    method _build__sorted_entries {
        my @entries = @{ $self->subtype_entries };

        idhash my %out;

        for my $entry (@entries) {
            $out{$entry} = [];

            for my $other (@entries) {
                next if refaddr $entry == refaddr $other;

                if ($other->type_constraint->is_subtype_of($entry->{type_constraint})) {
                    push @{ $out{$entry} }, $other;
                }
            }
        }

        my @sorted;

        while (keys %out) {
            my @slot;

            for my $entry (@entries) {
                if ($out{$entry} and !@{ $out{$entry} }) {
                    push @slot, $entry;
                    delete $out{$entry};
                }
            }

            idhash my %filter;
            @filter{@slot} = ();

            for my $entry (@entries) {
                if (my $out = $out{$entry}) {
                    @{ $out } = grep { !exists $filter{$_} } @{ $out };
                }
            }

            push @sorted, \@slot;
        }

        return \@sorted;
    }

    method has_entry_for ($type) {
        return ! !$self->resolve($type); # FIXME
    }

    method resolve ($type) {
        for my $entry (@{ $self->entries }) {
            return $entry->data if $entry->type_constraint->equals($type);
        }

        for my $slot (@{ $self->_sorted_entries }) {
            my @matches;

            for my $entry (@{ $slot }) {
                if ($type->equals($entry->type_constraint)
                 || $type->is_subtype_of($entry->type_constraint)) {
                    return $entry->data;
                }
            }
        }

        return;
    }
}
