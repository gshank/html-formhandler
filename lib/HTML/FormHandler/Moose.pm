package  HTML::FormHandler::Moose;

use Moose;
use Moose::Exporter;
use HTML::FormHandler::Meta::Class;

=head1 NAME

HTML::FormHandler::Moose - to add FormHandler sugar

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

   my $value = $class->meta->field_list || [];
   if( scalar @{$value} == 0 )
   {
      # first time in this class.
      foreach my $sc ( $class->meta->superclasses )
      {
         last if $sc eq 'HTML::FormHandler';
         if ( $sc->meta->can('field_list') )
         {
            push @{$value}, @{$sc->meta->field_list};
         }
      }
   }
   push @{$value}, ($name => \%options); 
   $class->meta->field_list($value);
}

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
