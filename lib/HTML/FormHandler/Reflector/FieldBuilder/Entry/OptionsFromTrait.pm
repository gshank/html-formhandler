use MooseX::Declare;

namespace HTML::FormHandler::Reflector::FieldBuilder;

class ::Entry::OptionsFromTrait
  with ::Entry {
    use MooseX::Types::Moose qw(RoleName Str);

    has trait => (
        is  => 'ro',
        isa => RoleName,
    );

    has option_reader => (
        is  => 'ro',
        isa => Str,
    );

    method match ($attr) { $attr->does($self->trait) }
    method apply ($attr) { %{ $attr->${ \$self->option_reader } || {} } }
}
