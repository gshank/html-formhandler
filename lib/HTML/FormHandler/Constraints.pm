package HTML::FormHandler::Constraints;

use Moose::Role;

has '_named_constraints' => (
   metaclass => 'Collection::Hash',
   is        => 'ro',
   isa       => 'HashRef',
   default   => sub { { } },
   provides  => {
      'set' => '_set_named_constraint',
      'get' => '_get_named_constraint',
      'empty' => '_has_named_constraints',
      'count' => '_num_named_constraints',
      'delete' => '_delete_named_constraint',
   }
);


sub _build_named_constraints
{
   my $self = shift;

   foreach my $sc ( reverse $self->meta->linearized_isa )
   {
      my $meta = $sc->meta;
      if( $meta->can('calculate_all_roles') )
      {
         foreach my $role ( $meta->calculate_all_roles )
         {
            if ( $role->can('meta_constraints') && $role->has_meta_constraints )
            {
               while (my ($name, $value) = each %{$role->meta_constraints} )
               {
                  $self->_set_named_constraint( $name, $value ); 
               }
            }
         }
      }
      if ( $meta->can('meta_constraints') && $meta->has_meta_constraints )
      {
         while ( my ($name, $value) = each %{$meta->meta_constraints} )
         {
            $self->_set_named_constraint( $name, $value ); 
         }
      }
   }
}

1;
