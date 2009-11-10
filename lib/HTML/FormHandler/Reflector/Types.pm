package HTML::FormHandler::Reflector::Types;

use MooseX::Types -declare => [qw/
    TypeMap
    TypeMapEntry
    FieldBuilder
    FieldBuilderEntry
/];

class_type TypeMap,      { class => 'HTML::FormHandler::Reflector::TypeMap'        };
class_type TypeMapEntry, { class => 'HTML::FormHandler::Reflector::TypeMap::Entry' };

class_type FieldBuilder,      { class => 'HTML::FormHandler::Reflector::FieldBuilder'        };
role_type  FieldBuilderEntry, { role  => 'HTML::FormHandler::Reflector::FieldBuilder::Entry' };

1;
