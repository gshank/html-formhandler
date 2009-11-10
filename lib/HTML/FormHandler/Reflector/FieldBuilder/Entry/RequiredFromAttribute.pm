use MooseX::Declare;

namespace HTML::FormHandler::Reflector::FieldBuilder;

class ::Entry::RequiredFromAttribute
  with ::Entry {
    method match ($attr) { 1 }
    method apply ($attr) { (required => $attr->is_required) }
}
