use MooseX::Declare;

namespace HTML::FormHandler::Reflector;

class ::FieldBuilder::Entry::ValidateWithConstraint
  with ::FieldBuilder::Entry {
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

