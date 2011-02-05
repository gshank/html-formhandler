package  HTML::FormHandler::Moose;
# ABSTRACT: to add FormHandler sugar

use Moose;
use Moose::Exporter;
use Moose::Util::MetaRole;
use HTML::FormHandler::Meta::Role;
use constant HAS_MOOSE_V109_METAROLE => ($Moose::VERSION >= 1.09);

=head1 SYNOPSIS

Enables the use of field specification sugar (has_field).
Use this module instead of C< use Moose; >

   package MyApp::Form::Foo;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'username' => ( type => 'Text', ... );
   has_field 'something_else' => ( ... );

   no HTML::FormHandler::Moose;
   1;

=cut

Moose::Exporter->setup_import_methods(
    with_meta => [ 'has_field', 'has_page', 'apply' ],
    also        => 'Moose',
);

sub init_meta {
    my $class = shift;

    my %options = @_;
    Moose->init_meta(%options);
    my $meta;
    if (HAS_MOOSE_V109_METAROLE) {
        $meta = Moose::Util::MetaRole::apply_metaroles(
            for             => $options{for_class},
            class_metaroles => {
                class => [ 'HTML::FormHandler::Meta::Role' ]
            }
        );
    } else {
        $meta = Moose::Util::MetaRole::apply_metaclass_roles(
            for_class       => $options{for_class},
            metaclass_roles => ['HTML::FormHandler::Meta::Role'],
        );
    }
    return $meta;
}

sub has_field {
    my ( $meta, $name, %options ) = @_;
    my $names = ( ref($name) eq 'ARRAY' ) ? $name : [ ($name) ];

    $meta->add_to_field_list( { name => $_, %options } ) for @$names;
}

sub has_page {
    my ( $meta, $name, %options ) = @_;
    my $names = ( ref($name) eq 'ARRAY' ) ? $name : [ ($name) ];

    $meta->add_to_page_list( { name => $_, %options } ) for @$names;
}

sub apply {
    my ( $meta, $arrayref ) = @_;

    $meta->add_to_apply_list( @{$arrayref} );
}

use namespace::autoclean;
1;
