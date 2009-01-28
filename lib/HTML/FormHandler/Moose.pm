package  # hide from Pause
   HTML::FormHandler::Moose;

use Moose;
use HTML::FormHandler::Meta::Class;

=head1 NAME

HTML::FormHandler::Moose - to add FormHandler sugar

=head1 SYNOPSIS

Enables the use of field specification sugar:

   has_field 'username' => ( type => 'Text', ... );

Use this module instead of C< use Moose; >

   package MyApp::Form::Foo;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   < define form>
  
   no HTML::FormHandler::Moose;
   1;
   
=cut

Moose::Exporter->setup_import_methods(
   with_caller => [ 'has_field' ],
   also        => 'Moose',
);

sub init_meta {
  shift;
  Moose->init_meta( @_, metaclass => 'HTML::FormHandler::Meta::Class' );
}

sub has_field
{
   my ( $class, $name, %options ) = @_;
   my $instance = Class::MOP::Class->initialize( 'HTML::FormHandler' );
   my $flist_attr = $instance->get_attribute('has_field_list');
   my $value = $flist_attr->get_value( $instance ) || [];
   push @{$value}, {$name => \%options};
   $flist_attr->set_value($instance, $value);
   $class->meta->field_list($value);
}

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
