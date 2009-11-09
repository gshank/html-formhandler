use MooseX::Declare;

namespace HTML::FormHandler::Reflector;

class ::FieldBuilder::Entry::TypeFromConstraint
  with ::FieldBuilder::Entry {
    use HTML::FormHandler::Reflector::Types qw(TypeMap);

    has typemap => (
        is => 'ro',
        isa => TypeMap,
    );

    method match ($attr) { 
        $attr->has_type_constraint && $self->typemap->has_entry_for($attr->type_constraint)
    }

    method apply ($attr) {
        $self->typemap->resolve($attr->type_constraint)->($attr);
    }
}
