package HTML::FormHandler::InitResult;

use Moose::Role;

# _init is for building fields when 
# there is no initial object and no params
# formerly _init
sub _result_from_fields
{
   my $self = shift;
   $self->clear_result if $self->has_result;
   my $self_result = $self->result;
   for my $field ( $self->fields )
   {
      next if $field->inactive;
      my $result = $field->_result_from_fields;
      $result->parent($self_result);
      $self_result->add_result($result);
   }
   return $self_result;
}

# building fields from input (params) 
# formerly done in validate_field
sub _result_from_input
{
   my ( $self, $input, $exists ) = @_;

   # transfer the input values to the input attributes of the
   # subfields
   $self->clear_result if $self->has_result;
   return unless ( defined $input || $exists );
   my $self_result = $self->result;
   $self_result->_set_input($input);
   if ( ref $input eq 'HASH' ) {
      foreach my $field ( $self->fields ) {
         next if $field->inactive;
         my $result;
         my $field_name = $field->name;
         # Trim values and move to "input" slot
         $result = $field->_result_from_input( $input->{$field_name}, exists $input->{$field_name} );
         if( $result )
         {
            $result->parent($self_result);
            $self_result->add_result($result);
         }
      }
   }
   return $self_result;
}

=pod

# building fields from model object or init_obj hash
# formerly _init_from_object
sub _result_from_object
{
   my ( $self, $item ) = @_;

   return unless $item;
   warn "HFH: init_from_object ", $self->name, "\n" if $self->verbose;
   my $my_value;
   for my $field_def ( $self->field_defs ) {
      next if $field_def->parent && $field_def->parent != $self;
      next if $field_def->writeonly;
      next if ref $item eq 'HASH' && !exists $item->{ $field_def->accessor };
      my $value = $self->_get_value( $field_def, $item );
      my $field = $field_def->_fields_from_object( $value );
      $my_value->{ $field->name } = $field->value;
   }
   $self->_set_value($my_value);
   $self->state->parent($self->parent->state) if $self->parent;
}

sub _get_value
{
   my ( $self, $field_def, $item ) = @_;
   my $accessor = $field_def->accessor;
   my @values;
   if ( blessed($item) && $item->can($accessor) ) {
      @values = $item->$accessor;
   }
   elsif ( exists $item->{$accessor} ) {
      @values = $item->{$accessor};
   }
   else {
      return;
   }
   my $value = @values > 1 ? \@values : shift @values;
   return $value;
}

=pod

   my $input = $self->input;
   # transfer the input values to the input attributes of the
   # subfields
   if ( ref $input eq 'HASH' ) {
      foreach my $field ( $self->fields ) {
         my $field_name = $field->name;
         # Trim values and move to "input" slot
         if ( exists $input->{$field_name} ) {
            $field->_set_input( $input->{$field_name} );
         }
         elsif ( $field->DOES('HTML::FormHandler::Field::Repeatable') ) {
            $field->clear_other;
         }
         elsif ( $field->has_input_without_param && !$field->inactive ) {
            $field->_set_input( $field->input_without_param );
         }
         if( $field->has_input && $field->parent )
         {
            $field->state->parent($field->parent->state);
            $self->state->add_child($field->state);
         }
      }
   }

=cut



1;
