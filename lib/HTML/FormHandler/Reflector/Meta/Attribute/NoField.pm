package HTML::FormHandler::Reflector::Meta::Attribute::NoField;

use Moose::Role;
use namespace::autoclean;

sub Moose::Meta::Attribute::Custom::Trait::FormHandler::NoField::register_implementation { __PACKAGE__ }

1;
