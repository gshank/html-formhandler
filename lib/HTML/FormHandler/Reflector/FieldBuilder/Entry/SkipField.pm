use MooseX::Declare;

namespace HTML::FormHandler::Reflector;

class ::FieldBuilder::Entry::SkipField
  with ::FieldBuilder::Entry {
    use MooseX::Types::Moose qw(CodeRef);

    has filter => (
        is => 'ro',
        isa => CodeRef,
    );

    method match ($attr) { $self->filter->($attr) }
    method apply ($attr) { (inactive => 1)        }
}
