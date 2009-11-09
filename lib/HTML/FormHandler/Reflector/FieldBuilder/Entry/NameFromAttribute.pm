use MooseX::Declare;

namespace HTML::FormHandler::Reflector::FieldBuilder;

class ::Entry::NameFromAttribute
  with ::Entry {
    method match ($attr) { 1 }
    method apply ($attr) { (name => $attr->name) }
}
