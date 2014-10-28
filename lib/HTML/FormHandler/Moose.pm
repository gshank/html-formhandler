package  HTML::FormHandler::Moose;
# ABSTRACT: to add FormHandler sugar

use Moose;
use Moose::Exporter;
use Moose::Util::MetaRole;
use HTML::FormHandler::Meta::Role;

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
    with_meta => [ 'has_field', 'has_page', 'has_block', 'apply' ],
    also        => 'Moose',
);

sub init_meta {
    my ( $class, %options ) = @_;

    Moose->init_meta(%options);
    my $meta = Moose::Util::MetaRole::apply_metaroles(
        for             => $options{for_class},
        class_metaroles => {
            class => [ 'HTML::FormHandler::Meta::Role' ]
        }
    );
    return $meta;
}

sub has_field {
    my ( $meta, $name, %options ) = @_;
    my $names = ( ref($name) eq 'ARRAY' ) ? $name : [ ($name) ];

    unless ($meta->found_hfh) {
        my @linearized_isa = $meta->linearized_isa;
        if( grep { $_ eq 'HTML::FormHandler' || $_ eq 'HTML::FormHandler::Field' } @linearized_isa ) {
            $meta->found_hfh(1);
        }
        else {
            die "Package '" . $linearized_isa[0] . "' uses HTML::FormHandler::Moose without extending HTML::FormHandler[::Field]";
        }
    }

    $meta->add_to_field_list( { name => $_, %options } ) for @$names;

    return;
}

sub has_page {
    my ( $meta, $name, %options ) = @_;
    my $names = ( ref($name) eq 'ARRAY' ) ? $name : [ ($name) ];

    $meta->add_to_page_list( { name => $_, %options } ) for @$names;

    return;
}

sub has_block {
    my ( $meta, $name, %options ) = @_;

    return $meta->add_to_block_list( { name => $name, %options } );
}

sub apply {
    my ( $meta, $arrayref ) = @_;

    return $meta->add_to_apply_list( @{$arrayref} );
}

use namespace::autoclean;
1;
