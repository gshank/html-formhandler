use MooseX::Declare;

namespace HTML::FormHandler::Reflector;

class ::FieldBuilder::Default
  extends ::FieldBuilder {
    use MooseX::Types::Moose qw(ClassName ArrayRef);
    use HTML::FormHandler::Reflector::Types qw(FieldBuilderEntry);

    use aliased 'HTML::FormHandler::Reflector::TypeMap::Default', 'DefaultTypeMap';
    use aliased 'HTML::FormHandler::Reflector::Meta::Attribute::Field', 'FieldTrait';
    use aliased 'HTML::FormHandler::Reflector::Meta::Attribute::NoField', 'NoFieldTrait';
    use aliased 'HTML::FormHandler::Reflector::FieldBuilder::Entry::SkipField';
    use aliased 'HTML::FormHandler::Reflector::FieldBuilder::Entry::NameFromAttribute';
    use aliased 'HTML::FormHandler::Reflector::FieldBuilder::Entry::RequiredFromAttribute';
    use aliased 'HTML::FormHandler::Reflector::FieldBuilder::Entry::TypeFromConstraint';
    use aliased 'HTML::FormHandler::Reflector::FieldBuilder::Entry::ValidateWithConstraint';
    use aliased 'HTML::FormHandler::Reflector::FieldBuilder::Entry::OptionsFromTrait';

    has typemap_class => (
        is      => 'ro',
        isa     => ClassName,
        default => DefaultTypeMap,
    );

    has typemap_args => (
        is      => 'ro',
        isa     => ArrayRef,
        default => sub { [] },
    );

    has extra_entries => (
        is      => 'ro',
        isa     => ArrayRef[FieldBuilderEntry],
        builder => '_build_extra_entries',
    );

    method _build_extra_entries { [] }

    method _build_entries {
        return [
            SkipField->new({
                filter => method ($attr:) {
                    $attr->does(NoFieldTrait)
                     || !$attr->has_write_method
                     || $attr->name =~ /^_/
                }->body,
            }),
            NameFromAttribute->new,
            TypeFromConstraint->new({
                typemap => $self->typemap_class->new(@{ $self->typemap_args }),
            }),
            ValidateWithConstraint->new,
            OptionsFromTrait->new({
                trait => FieldTrait,
                option_reader => 'form',
            }),
            @{ $self->extra_entries },
        ];
    }
}
