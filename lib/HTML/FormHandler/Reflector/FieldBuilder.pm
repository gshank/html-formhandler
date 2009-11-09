use MooseX::Declare;

class HTML::FormHandler::Reflector::FieldBuilder {
    use MooseX::Types::Moose qw(ArrayRef);
    use HTML::FormHandler::Reflector::Types qw(FieldBuilderEntry);

    has entries => (
        is => 'ro',
        isa => ArrayRef[FieldBuilderEntry],
        lazy => 1,
        builder => '_build_entries',
    );

    method _build_entries { [] }

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

1;
