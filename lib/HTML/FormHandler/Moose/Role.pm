package HTML::FormHandler::Moose::Role;
# ABSTRACT: to add sugar to roles

use Moose::Role;
use Moose::Exporter;

=head1 SYNOPSIS

Enables the use of field specification sugar (has_field) in roles.
Use this module instead of C< use Moose::Role; >

   package MyApp::Form::Foo;
   use HTML::FormHandler::Moose::Role;

   has_field 'username' => ( type => 'Text', ... );
   has_field 'something_else' => ( ... );

   no HTML::FormHandler::Moose::Role;
   1;

=cut

Moose::Exporter->setup_import_methods(
    with_caller => [ 'has_field', 'has_block', 'apply' ],
    also        => 'Moose::Role',
);

sub init_meta {
    my $class = shift;

    my %options = @_;
    Moose::Role->init_meta(%options);
    my $meta = Moose::Util::MetaRole::apply_metaroles(
        for            => $options{for_class},
        role_metaroles => { role => ['HTML::FormHandler::Meta::Role'] }
    );

    return $meta;
}

sub has_field {
    my ( $class, $name, %options ) = @_;

    $class->meta->add_to_field_list( { name => $name, %options } );
}

sub has_block {
    my ( $class, $name, %options ) = @_;
    $class->meta->add_to_block_list( { name => $name, %options } );
}

sub apply {
    my ( $class, $arrayref ) = @_;
    $class->meta->add_to_apply_list( @{$arrayref} );
}

use namespace::autoclean;
1;
