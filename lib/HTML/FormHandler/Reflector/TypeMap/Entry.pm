use MooseX::Declare;

class HTML::FormHandler::Reflector::TypeMap::Entry {
    has type_constraint => (
        is  => 'ro',
        isa => 'Moose::Meta::TypeConstraint',
    );

    has data => (
        is => 'ro',
    );
}
