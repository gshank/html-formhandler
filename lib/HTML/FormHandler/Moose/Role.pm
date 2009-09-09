package HTML::FormHandler::Moose::Role;

use Moose::Role;
use Moose::Exporter;

=head1 NAME

HTML::FormHandler::Moose::Role - to add FormHandler sugar to Roles

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
    with_caller => [ 'has_field', 'apply' ],
    also        => 'Moose::Role',
);

sub init_meta {
    my $class = shift;

    my %options = @_;
    Moose::Role->init_meta(%options);
    my $meta = Moose::Util::MetaRole::apply_metaclass_roles(
        for_class       => $options{for_class},
        metaclass_roles => ['HTML::FormHandler::Meta::Role'],
    );
    return $meta;
}

sub has_field {
    my ( $class, $name, %options ) = @_;

    $class->meta->add_to_field_list( { name => $name, %options } );
}

sub apply {
    my ( $class, $arrayref ) = @_;
    $class->meta->add_to_apply_list( @{$arrayref} );
}

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

use namespace::autoclean;
1;
