package HTML::FormHandler::Reflector::Meta::Attribute::Field;

use Moose::Role;
use MooseX::Types::Moose qw/HashRef/;
use namespace::autoclean;

has form => (
    is  => 'ro',
    isa => HashRef,
);

sub Moose::Meta::Attribute::Custom::Trait::FormHandler::Field::register_implementation { __PACKAGE__ }

1;
