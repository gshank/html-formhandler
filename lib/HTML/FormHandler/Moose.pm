package  # hide from Pause
   HTML::FormHandler::Moose;

use Moose;
use HTML::FormHandler::Meta::Class;

=head1 NAME

HTML::FormHandler::Moose - to add FormHandler sugar

=head1 SYNOPSIS

   package MyApp::Form::Foo;

   use HTML::FormHandler::Moose;

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
   my ( $caller, $name, %options ) = @_;

   my $obj = Class::MOP::Class->initialize( $caller );
   my $list = $caller->meta->field_list || [];
   push @{$list}, ($name => \%options);
   $caller->meta->field_list($list);
   $list = $caller->meta->field_list;
}

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
