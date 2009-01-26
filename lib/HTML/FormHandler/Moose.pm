package  # hide from Pause
   HTML::FormHandler::Moose;

use Moose;
use HTML::FormHandler::Meta::Class;

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

1;
