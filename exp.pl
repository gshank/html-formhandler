use MooseX::Declare;

class FieldBuilder {
    has entries => (
        is => 'ro',
        isa => 'ArrayRef[FieldBuilder::Entry]',
    );

    method resolve ($attr) {
        return {
            map {
                $_->match($attr)
                    ? $_->apply($attr)
                    : ()
            } @{ $self->entries },
        };
    }
}

role FieldBuilder::Entry {
    requires qw(match apply);
}

class FieldBuilder::Entry::SkipField
  with FieldBuilder::Entry {
    has filter => (
        is => 'ro',
        isa => 'CodeRef',
    );

    method match ($attr) { $self->filter->($attr) }
    method apply ($attr) { (inactive => 1)        }
}

class FieldBuilder::Entry::ValidateWithConstraint
  with FieldBuilder::Entry {
    method match ($attr) { $attr->has_type_constraint }
    method apply ($attr) {
        (apply => [
            { check   => method ($val:) { $attr->type_constraint->check($val) }->body,
              message => 'FIXME' },
            ($attr->type_constraint->has_coercion
                ? ({ transform => method ($val:) { $attr->type_constraint->coerce($val) }->body })
                : ()),
        ])
    }
}

class FieldBuilder::Entry::TypeFromConstraint
  with FieldBuilder::Entry {
    has typemap => (
        is => 'ro',
        isa => 'TypeMap',
    );

    method match ($attr) { 
        $attr->has_type_constraint && $self->typemap->has_entry_for($attr->type_constraint)
    }

    method apply ($attr) {
        $self->typemap->resolve($attr->type_constraint)->($attr);
    }
}

class TypeMap {
    use Scalar::Util 'refaddr';
    use Hash::Util::FieldHash::Compat 'idhash';

    has entries => (
        is => 'ro',
        isa => 'ArrayRef[TypeMap::Entry]',
        builder => '_build_entries',
    );

    has subtype_entries => (
        is => 'ro',
        isa => 'ArrayRef[TypeMap::Entry]',
        builder => '_build_subtype_entries',
    );

    has _sorted_entries => (
        is => 'ro',
        isa => 'ArrayRef[ArrayRef[TypeMap::Entry]]',
        lazy => 1,
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

class TypeMap::Entry {
    has type_constraint => (
        is => 'ro',
        isa => 'Moose::Meta::TypeConstraint',
    );

    has data => (
        is => 'ro',
    );
}

class User {
    has id => (is => 'ro', isa => 'Int');
    has name => (is => 'rw', isa => 'Str');
    has stuffz => (is => 'rw', isa => 'Int');
}

use MooseX::Types::Moose qw(Str Num Int);
use MooseX::Method::Signatures;

my $fb = FieldBuilder->new({
    entries => [
        FieldBuilder::Entry::SkipField->new({
            filter => method ($attr:) {
                $attr->does('NoField')
                 || !$attr->has_write_method
                 || $attr->name =~ /^_/
             }->body,
        }),
        FieldBuilder::Entry::TypeFromConstraint->new({
            typemap => TypeMap->new({
                entries => [
                    TypeMap::Entry->new({
                        type_constraint => Str,
                        data => sub { (type => 'TextArea') },
                    }),
                ],
                subtype_entries => [
                    TypeMap::Entry->new({
                        type_constraint => Num,
                        data => sub { (type => 'Text') },
                    }),
                ],
            }),
        }),
        FieldBuilder::Entry::ValidateWithConstraint->new({
        }),
    ],
});

use Data::Dump 'pp';

pp $fb->resolve($_) for User->meta->get_all_attributes;
